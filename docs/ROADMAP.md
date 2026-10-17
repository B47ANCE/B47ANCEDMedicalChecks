# Current disposition

Project Version: 0.3.0-dev.7

Examination requests, remembered examiners, individual revocation, server policies,
request timing and persistence are implemented for offline validation. Current
player-facing text describes these features without repeated security warnings.
The .6 compatibility update keeps Medical Checks standalone and makes
its runtime inactive while Health Care is enabled. The request logic, protocol,
storage format and treatment behavior remain unchanged when running standalone.

The .7 validation/UI checkpoint adds isolated server/three-client message-routing
fixtures, a Lua 5.1/5.4 host selection, controller navigation/focus and small
split-screen placement fixes. Publication documentation follows per-upload Steam
restart confirmation. No new gameplay option or storage/protocol change is added.

Next: separately authorized player-hosted and dedicated multiplayer tests covering
approval/denial, UI/controller/split-screen, storage, reconnect and restart.
G7 NOT TESTED / BLOCKED; stable G8 BLOCKED. No automatic packaging, deployment,
game/server launch or publication.

Use TESTING.md and RUNTIME_TEST_RECORD.md to run and record the remaining gates.
English fallback is supported in all 29 locale folders; native-language
translations are optional contributor work, not claimed translated coverage.

Health Care is planned to absorb all Medical Checks features. The standalone
project and existing Workshop item continue independently. Actual Health Care
feature absorption and any explicit data-migration design are separate future work.
