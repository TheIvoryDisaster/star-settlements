#!/usr/bin/env python3
"""Repository hygiene checks only. Not a compiler or game test."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
required = ["README.md", "docs/FEASIBILITY.md", "docs/ENGINE_SPIKES.md",
            "docs/ARCHITECTURE.md", "docs/PERFORMANCE.md", "docs/ENVIRONMENT.md",
            "docs/SOURCES.md", "config/project-targets.json"]
missing = [name for name in required if not (root / name).is_file()]
assert not missing, f"Missing required files: {missing}"
settings = json.loads((root / "config/project-targets.json").read_text(encoding="utf-8"))
assert settings["phase"] == "feasibility", "Update verification as implementation phase begins"
assert settings["prefix"] == "SCS_"
blocked = {".esp", ".esl", ".ba2", ".pex", ".dll", ".exe", ".bsa"}
violations = [str(path.relative_to(root)) for path in root.rglob("*")
              if path.is_file() and ".git" not in path.parts and (path.suffix.lower() in blocked or
                 (path.suffix.lower() == ".esm" and not (path.parent == root / "plugins" and path.name.startswith("SCS_"))))]
assert not violations, f"Generated/restricted binaries need a separate artifact workflow: {violations}"
print("OK: Feasibility repository has expected docs/config and no generated game binaries.")
print("NOTE: Papyrus, Creation Kit, AI, save data, and performance are NOT tested by this check.")
