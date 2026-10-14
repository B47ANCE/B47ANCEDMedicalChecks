# Preserved historical evidence

The existing native/, research/, dist/current/ and handoff/ files are retained in
place without deletion or version rewriting. Editable source/scripts/tests/docs
were copied into history/java-era-0.1.0-dev.1/ before conversion. Its local
preservation-manifest.json records SHA-256 for 91 copied files and 57 retained
research/artifact files. The current offline test verifies those protected hashes.

Those trees are ignored by Git and excluded from active package inputs. Public
source contains an evidence hash baseline and new audit summary, not decompiled
game source, Java agents/binaries, local diagnostic snapshots or launch instructions.
Old Java build code is preserved under history; scripts/build.py now runs only
Python/Lua static/offline checks. Preserving evidence is not approval to execute it.

The historical 52-test/31-native-assertion reports do not apply to this iteration.
No cleanup, migration of real saves, artifact replacement or external game/mod edit
occurred. Local retained evidence is not claimed as uploaded GitHub backup.
