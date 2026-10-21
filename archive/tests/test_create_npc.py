from __future__ import annotations

import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "create-npc"


def run_generator(*arguments: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *arguments],
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )


class CreateNpcTests(unittest.TestCase):
    def test_no_arguments_produces_complete_markdown(self) -> None:
        result = run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertRegex(result.stdout, r"(?m)^# .+")
        self.assertIn("## History", result.stdout)
        self.assertIn("## On Their Person", result.stdout)
        self.assertIn("## Stat Block", result.stdout)
        self.assertIn("#### Actions", result.stdout)
        self.assertRegex(result.stdout, r"Generation seed: `\d+`")

    def test_seed_is_deterministic(self) -> None:
        first = run_generator("--seed", "424242")
        second = run_generator("--seed", "424242")
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(first.stdout, second.stdout)

    def test_lock_ins_appear_in_output(self) -> None:
        result = run_generator(
            "--seed", "19",
            "--name", "Mara Vell",
            "--species", "dwarf",
            "--gender", "woman",
            "--pronouns", "she-her",
            "--age", "80",
            "--location", "phandalin",
            "--origin", "mirabar",
            "--occupation", "blacksmith",
            "--faction", "harpers",
            "--faith", "moradin",
            "--alignment", "lawful-good",
            "--archetype", "warrior",
            "--cr", "3",
            "--magic-item", "none",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        for expected in (
            "# Mara Vell", "| Species | Dwarf |", "| Age | 80 (adult) |",
            "| Gender and pronouns | Woman; she/her |", "| Occupation | Blacksmith |",
            "| Current location | Phandalin", "| Origin | Mirabar |",
            "| Faith | Moradin", "| Affiliation | Harpers", "| Alignment | Lawful Good |",
            "| Combat profile | Warrior, CR 3 |", "**CR** 3 (XP 700; PB +2)",
        ):
            self.assertIn(expected, result.stdout)

    def test_help_enumerates_supported_lock_ins(self) -> None:
        result = run_generator("--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("LOCK-IN VALUES", result.stdout)
        self.assertIn("neverwinter-wood", result.stdout)
        self.assertIn("blacksmith", result.stdout)
        self.assertIn("emerald-enclave", result.stdout)
        self.assertIn("yondalla", result.stdout)
        self.assertIn("arcanist", result.stdout)

    def test_batch_names_are_unique_and_document_is_structured(self) -> None:
        result = run_generator("--seed", "888", "--count", "25")
        self.assertEqual(result.returncode, 0, result.stderr)
        names = re.findall(r"(?m)^## ([^#\n].+)$", result.stdout)
        npc_names = [name for name in names if name not in {"Stat Block"}]
        self.assertEqual(len(npc_names), 25)
        self.assertEqual(len({name.casefold() for name in npc_names}), 25)
        self.assertTrue(result.stdout.startswith("# Generated Sword Coast NPCs"))

    def test_every_cr_generates(self) -> None:
        for cr in ("0", "1/8", "1/4", "1/2", "1", "2", "3", "4", "5"):
            with self.subTest(cr=cr):
                result = run_generator("--seed", "71", "--cr", cr)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(f"**CR** {cr} (", result.stdout)

    def test_every_archetype_generates_at_high_cr(self) -> None:
        archetypes = (
            "civilian", "expert", "guard", "scout", "outlaw", "warrior",
            "leader", "devotee", "arcanist",
        )
        for archetype in archetypes:
            with self.subTest(archetype=archetype):
                result = run_generator("--seed", "93", "--archetype", archetype, "--cr", "5")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(f"| Combat profile |", result.stdout)
                self.assertIn("CR 5 |", result.stdout)
                self.assertIn("**CR** 5 (XP 1,800; PB +3)", result.stdout)

    def test_every_species_generates_with_a_valid_age(self) -> None:
        species = (
            "human", "dwarf", "elf", "halfling", "gnome", "half-elf", "orc",
            "half-orc", "tiefling", "dragonborn", "goliath", "aasimar", "goblin",
        )
        for value in species:
            with self.subTest(species=value):
                result = run_generator("--seed", "37", "--species", value)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("## Stat Block", result.stdout)

    def test_output_file_and_overwrite_protection(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "npc.md"
            first = run_generator("--seed", "1", "--output", str(destination))
            self.assertEqual(first.returncode, 0, first.stderr)
            self.assertTrue(destination.exists())
            self.assertIn("## Stat Block", destination.read_text(encoding="utf-8"))
            second = run_generator("--seed", "2", "--output", str(destination))
            self.assertNotEqual(second.returncode, 0)
            self.assertIn("use --force", second.stderr)
            third = run_generator("--seed", "2", "--output", str(destination), "--force")
            self.assertEqual(third.returncode, 0, third.stderr)
            self.assertIn("Generation seed: `2`", destination.read_text(encoding="utf-8"))

    def test_invalid_cr_range_is_rejected(self) -> None:
        result = run_generator("--min-cr", "3", "--max-cr", "1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--min-cr cannot be greater", result.stderr)


if __name__ == "__main__":
    unittest.main()

