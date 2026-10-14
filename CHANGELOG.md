# Changelog

## [0.2.0-dev.2]

PR #1 review fixes: rapid metadata mutations return an explicit retry status and restore the saved selection; integer-valued floating-point preferences use canonical storage encoding. Added offline regressions and documented uncertain read-back failures. Consent enforcement remains BLOCKED; dedicated multiplayer NOT TESTED; stable G8 BLOCKED.

## [0.2.0-dev.1]

Lua-only conversion. Incompatible 0.x scope change: Java integration removed from active code/build/package paths; examination consent enforcement blocked rather than weakened. Existing agent properties are retained, not automatically imported.


## [0.1.0-dev.1]

Initial implementation of account consent, policy controls, permission management,
and a server packet guard. Dedicated runtime verification remains outstanding.
