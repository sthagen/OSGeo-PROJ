-- Version of the database structure.
-- The major number indicates an incompatible change (e.g. table or column
-- removed or renamed).
-- The minor number is incremented if a backward compatible change done, that
-- is the new database can still work with an older PROJ version.
-- When updating those numbers, the DATABASE_LAYOUT_VERSION_MAJOR and
-- DATABASE_LAYOUT_VERSION_MINOR constants in src/iso19111/factory.cpp must be
-- updated as well.
INSERT INTO "metadata" VALUES('DATABASE.LAYOUT.VERSION.MAJOR', 1);
INSERT INTO "metadata" VALUES('DATABASE.LAYOUT.VERSION.MINOR', 0);

-- TODO at next update remove exception case for EPSG:9658 to 9661 in commit.sql and EPSG:9659 and 9661 in customizations.sql
INSERT INTO "metadata" VALUES('EPSG.VERSION', 'v10.017');
INSERT INTO "metadata" VALUES('EPSG.DATE', '2021-04-01');
