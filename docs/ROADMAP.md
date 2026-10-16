# Current disposition

Project Version: 0.3.0-dev.6

Examination requests, remembered examiners, individual revocation, server policies,
request timing and persistence are implemented for offline validation. Current
player-facing text describes these features without repeated security warnings.
The 0.3.0-dev.6 compatibility update keeps Medical Checks standalone and makes
its runtime inactive while Health Care is enabled. The request logic, protocol,
storage format and treatment behavior remain unchanged when running standalone.

Next: separately authorized player-hosted and dedicated multiplayer tests covering
approval/denial, UI/controller/split-screen, storage, reconnect and restart.
G7 NOT TESTED / BLOCKED; stable G8 BLOCKED. No automatic packaging, deployment,
game/server launch or publication.

Health Care is planned to absorb all Medical Checks features. The standalone
project and existing Workshop item continue independently. Actual Health Care
feature absorption and any explicit data-migration design are separate future work.
