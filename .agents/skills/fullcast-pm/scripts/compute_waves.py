#!/usr/bin/env python3
"""compute_waves.py - topological ordering, cycle detection, and execution-wave
assignment for a PRD's dependency graph (architecture.md §5: this is a real algorithm,
not a "read a field and add 1" operation, so it earns being a script instead of the
model reasoning through a graph by hand).

Usage:
    echo '<json>' | compute_waves.py

Input (stdin), one JSON object mapping feature id -> {priority, dependencies}:

    {
      "F01": {"priority": 1, "dependencies": []},
      "F02": {"priority": 1, "dependencies": ["F01"]},
      "F03": {"priority": 2, "dependencies": ["F01"]}
    }

Output (stdout), one JSON object:

    {
      "order": ["F01", "F02", "F03"],
      "waves": {"1": ["F01"], "2": ["F02", "F03"]}
    }

`order` is a topological order, tie-broken by feature id (lower id first) — this is
what the PRD's Section 8 dependency TABLE should follow (every dependency appears
above the row that references it).

`waves` follows: wave(feature) = max(wave(dep) for dep in dependencies) + 1, with
wave 1 = every feature with no dependencies. Within a wave, keys are ordered by
priority ascending then by feature id, matching the PRD's Execution Waves rules.

On a cycle, prints an error object to stdout and exits 1:

    {"error": "cycle", "cycle": ["F03", "F05", "F03"]}

The model is responsible for building the input JSON from the PRD content it is
drafting, and for rendering `order`/`waves` back into the PRD's Markdown table and
bullet list — this script only does the graph math.
"""
import json
import sys


def find_cycle(features):
    """Returns a cycle (list of ids) if one exists, else None."""
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {fid: WHITE for fid in features}
    path = []

    def visit(fid):
        color[fid] = GRAY
        path.append(fid)
        for dep in features[fid]["dependencies"]:
            if dep not in features:
                raise ValueError(f"unknown dependency '{dep}' referenced by '{fid}'")
            if color[dep] == GRAY:
                cycle_start = path.index(dep)
                return path[cycle_start:] + [dep]
            if color[dep] == WHITE:
                found = visit(dep)
                if found:
                    return found
        color[fid] = BLACK
        path.pop()
        return None

    for fid in sorted(features):
        if color[fid] == WHITE:
            found = visit(fid)
            if found:
                return found
    return None


def topological_order(features):
    """Kahn's algorithm, tie-broken by feature id ascending."""
    in_degree = {fid: 0 for fid in features}
    dependents = {fid: [] for fid in features}
    for fid, data in features.items():
        for dep in data["dependencies"]:
            in_degree[fid] += 1
            dependents[dep].append(fid)

    ready = sorted([fid for fid, deg in in_degree.items() if deg == 0])
    order = []
    while ready:
        ready.sort()
        current = ready.pop(0)
        order.append(current)
        for dependent in dependents[current]:
            in_degree[dependent] -= 1
            if in_degree[dependent] == 0:
                ready.append(dependent)
    return order


def compute_waves(features, order):
    wave_of = {}
    for fid in order:
        deps = features[fid]["dependencies"]
        wave_of[fid] = 1 if not deps else max(wave_of[d] for d in deps) + 1

    waves = {}
    for fid, wave in wave_of.items():
        waves.setdefault(wave, []).append(fid)

    for wave in waves:
        waves[wave].sort(key=lambda fid: (features[fid].get("priority", 3), fid))

    return {str(k): v for k, v in sorted(waves.items())}


def main():
    raw = sys.stdin.read()
    try:
        features = json.loads(raw)
    except json.JSONDecodeError as e:
        print(json.dumps({"error": "invalid_json", "detail": str(e)}))
        sys.exit(2)

    if not isinstance(features, dict) or not features:
        print(json.dumps({"error": "invalid_input", "detail": "expected a non-empty object of feature id -> {priority, dependencies}"}))
        sys.exit(2)

    try:
        cycle = find_cycle(features)
    except ValueError as e:
        print(json.dumps({"error": "invalid_dependency", "detail": str(e)}))
        sys.exit(2)

    if cycle:
        print(json.dumps({"error": "cycle", "cycle": cycle}))
        sys.exit(1)

    order = topological_order(features)
    waves = compute_waves(features, order)
    print(json.dumps({"order": order, "waves": waves}, indent=2))


if __name__ == "__main__":
    main()
