#!/usr/bin/env python3
"""
check-relation-mapping.py — JI-004c relation-mapping coverage probe (W3).

Asserts every external IRI used in src/ontology/**/*.ttl appears in
docs/relation-mapping.md. Implements JI-008 §137 item (b) as a static
cross-reference scan. Stays in the Tester lane: reads src/ontology/ and
docs/relation-mapping.md but writes neither.

Failure mode is "IRI exists but isn't documented" — a documentation gap,
not a model bug. Therefore W3 is a WARNING gate by default. ADR can
promote to blocking once the registry matures (see CI-GATES.md).

Usage:
    python3 scripts/check-relation-mapping.py

Exit codes:
    0 = all external IRIs documented (or nothing to scan)
    1 = uncovered IRIs found (warning fires)
    2 = harness misconfiguration (missing files, parse errors)
"""

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
TBOX_GLOB = "src/ontology/**/*.ttl"
MAPPING_DOC = REPO_ROOT / "docs" / "relation-mapping.md"

# Namespace prefixes that count as "external" — IRIs under these are
# subject to the coverage check. Project-internal namespaces (ex:, jio:,
# owl:, rdf:, rdfs:, xsd:) are excluded.
EXTERNAL_PREFIXES = (
    "http://purl.obolibrary.org/obo/",
    "https://www.commoncoreontologies.org/",
)

RE_PREFIX = re.compile(r"^\s*@prefix\s+([\w-]*):\s*<([^>]+)>\s*\.", re.MULTILINE)
RE_FULL_IRI = re.compile(r"<([^>]+)>")
RE_PREFIXED = re.compile(r"(?:^|[\s,;\(\[])([a-zA-Z][\w-]*):([\w-]+)")
RE_COMMENT = re.compile(r"#.*?$", re.MULTILINE)


def is_external(iri: str) -> bool:
    return any(iri.startswith(p) for p in EXTERNAL_PREFIXES)


def extract_external_iris(ttl_path: Path) -> set:
    """Return set of full external IRIs referenced in a Turtle file."""
    # utf-8-sig auto-strips a leading BOM if present. Without this, a
    # BOM-prefixed Turtle file would defeat the @prefix line regex and
    # silently degrade extraction to namespace bases only — which then
    # trivially substring-match the mapping doc, giving false-PASS.
    text = ttl_path.read_text(encoding="utf-8-sig")
    text = RE_COMMENT.sub("", text)

    prefixes = {m.group(1): m.group(2) for m in RE_PREFIX.finditer(text)}
    body = RE_PREFIX.sub("", text)

    iris = set()
    for m in RE_FULL_IRI.finditer(body):
        iri = m.group(1)
        if is_external(iri):
            iris.add(iri)
    for m in RE_PREFIXED.finditer(body):
        prefix, local = m.group(1), m.group(2)
        if prefix in prefixes:
            base = prefixes[prefix]
            if is_external(base):
                iris.add(base + local)
    return iris


def check_coverage(iris, mapping_text: str):
    """Return sorted list of IRIs NOT found as substrings in the mapping doc."""
    return sorted(iri for iri in iris if iri not in mapping_text)


def main() -> int:
    if not MAPPING_DOC.exists():
        print(f"::error::Mapping doc not found at {MAPPING_DOC}", file=sys.stderr)
        return 2

    ttl_files = sorted(REPO_ROOT.glob(TBOX_GLOB))
    if not ttl_files:
        print("  SKIP: no T-Box files under src/ontology/.")
        return 0

    mapping_text = MAPPING_DOC.read_text(encoding="utf-8")

    per_file = {}
    all_iris = set()
    for f in ttl_files:
        try:
            file_iris = extract_external_iris(f)
        except OSError as e:
            print(f"::error::Cannot read {f}: {e}", file=sys.stderr)
            return 2
        per_file[f.relative_to(REPO_ROOT)] = file_iris
        all_iris |= file_iris

    uncovered = check_coverage(all_iris, mapping_text)
    covered_count = len(all_iris) - len(uncovered)

    print(f"Coverage scan against {MAPPING_DOC.relative_to(REPO_ROOT)}:")
    print(f"  scanned: {len(ttl_files)} T-Box file(s)")
    for relpath, iris in per_file.items():
        print(f"    - {relpath} ({len(iris)} external IRIs)")
    print(f"  external IRIs found: {len(all_iris)}")
    print(f"  covered: {covered_count}")
    print(f"  uncovered: {len(uncovered)}")

    if not uncovered:
        print("PASS: all external IRIs documented in relation-mapping.md.")
        return 0

    print()
    print("UNCOVERED IRIs (Onto: add to docs/relation-mapping.md):")
    for iri in uncovered:
        sources = [str(p) for p, ir in per_file.items() if iri in ir]
        print(f"  - {iri}")
        for s in sources:
            print(f"      from: {s}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
