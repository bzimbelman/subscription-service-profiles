# maps/

Drop FHIR Mapping Language (`.fml`) files here. Each map is referenced by a `mappings[].map` entry in `manifest.yaml`.

A map takes one inbound message shape (HL7 v2 segment tree, a FHIR resource, or a vendor-specific JSON payload) and emits a FHIR R4 Bundle. Maps run inside Matchbox via the engine's `$transform` operation.

See the engine repo's `docs/architecture.md` for the StructureMap execution model.
