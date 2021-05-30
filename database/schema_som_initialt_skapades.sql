-- Database: database

-- Extensions
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION postgis_raster;

CREATE TABLE geometri (
    id SERIAL PRIMARY KEY,
    polygon GEOMETRY, -- geometry är datatypen
    shape_area FLOAT
);

CREATE TABLE riksintresse (
    id SERIAL PRIMARY KEY,
    namn VARCHAR(60) NOT NULL,
    beskrivning TEXT,
    motivering TEXT,
    cederat BOOLEAN, -- avstått anspråk
    version INT DEFAULT 1,

    geometri_id INT NOT NULL,
    FOREIGN KEY (geometri_id) REFERENCES geometri(id)
);

-- KOMMUN OCH LÄN --
-- kommunkod & länskod enligt https://www.scb.se/hitta-statistik/regional-statistik-och-kartor/regionala-indelningar/lan-och-kommuner/lan-och-kommuner-i-kodnummerordning/

CREATE TABLE lan ( -- län
    kod INT PRIMARY KEY,
    namn VARCHAR(20) NOT NULL
);

CREATE TABLE kommun (
    kod INT PRIMARY KEY,
    namn VARCHAR(20) NOT NULL,

    lan_kod INT NOT NULL,
    FOREIGN KEY (lan_kod) REFERENCES lan(kod)
);

CREATE TABLE riksintresse_i_kommun ( -- kopplar riksintresse till kommuner där det geografiska området ligger
    id SERIAL PRIMARY KEY,

    riksintresse_id INT NOT NULL,
    FOREIGN KEY (riksintresse_id) REFERENCES riksintresse(id),
    kommun_kod INT NOT NULL,
    FOREIGN KEY (kommun_kod) REFERENCES kommun(kod)
);

-- KULTURMILJÖTYP --

CREATE TABLE kulturmiljotyp  ( -- kulturmiljötyp
    id SERIAL PRIMARY KEY,
    namn VARCHAR(60) NOT NULL
);

CREATE TABLE riksintresse_har_kulturmiljotyp  ( -- riksintresse kopplade till kulturmiljötyper
    riksintresse_id INT NOT NULL,
    FOREIGN KEY (riksintresse_id) REFERENCES riksintresse(id),
    kulturmiljotyp_id INT NOT NULL,
    FOREIGN KEY (kulturmiljotyp_id) REFERENCES kulturmiljotyp(id)
);

-- DOKUMENT KOPPLADE TILL RIKSINTRESSEN --

CREATE TABLE beslut ( -- kopplade till dokumenten, status behövs inte då de nyaste dokumenten är de som gäller.
    id SERIAL PRIMARY KEY,
    typ VARCHAR(20) NOT NULL
);

CREATE TABLE dokument (
    id SERIAL PRIMARY KEY,
    path TEXT NOT NULL,

    beslut_id INT NOT NULL,
    FOREIGN KEY (beslut_id) REFERENCES beslut(id),
    riksintresse_id INT NOT NULL,
    FOREIGN KEY (riksintresse_id) REFERENCES riksintresse(id)
);

CREATE TABLE bilder (
    id SERIAL PRIMARY KEY,
    path TEXT NOT NULL,

    riksintresse_id INT NOT NULL,
    FOREIGN KEY (riksintresse_id) REFERENCES riksintresse(id)
);

CREATE TABLE vidareläsning ( -- vidareläsning
    id SERIAL PRIMARY KEY,
    url TEXT NOT NULL,
    kommentar TEXT,

    riksintresse_id INT NOT NULL,
    FOREIGN KEY (riksintresse_id) REFERENCES riksintresse(id)
);

-- ADMINISTRATION --

CREATE TABLE roll ( -- roller, admin, handläggare
    id SERIAL PRIMARY KEY,
    titel VARCHAR(20) NOT NULL
);

CREATE TABLE anvandare ( -- användarna
    id SERIAL PRIMARY KEY,
    namn VARCHAR(20) NOT NULL,
    losenord TEXT NOT NULL,
    skapades TIMESTAMP NOT NULL DEFAULT clock_timestamp(), -- datum användaren registreras
    
    roll_id INT NOT NULL,
    FOREIGN KEY (roll_id) REFERENCES roll(id)
);

CREATE TABLE sakerhetslogg  ( -- säkerhetslogg, med info om vad användarna gör
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    ip VARCHAR(20) NOT NULL,
    action VARCHAR(20) NOT NULL,

    anvandare_id INT NOT NULL,
    FOREIGN KEY (anvandare_id) REFERENCES anvandare(id)
);

-- VERSIONER --

CREATE TABLE tidigare_version (
    namn VARCHAR(60) NOT NULL,
    beskrivning TEXT,
    motivering TEXT,
    cederat BOOLEAN,

    datum TIMESTAMP NOT NULL DEFAULT clock_timestamp(),

    id INT NOT NULL,
    FOREIGN KEY (id) REFERENCES riksintresse(id),

    geometri_id INT NOT NULL,
    FOREIGN KEY (geometri_id) REFERENCES geometri(id)
);

/* ANVÄNDS EJ */
CREATE TABLE riksintresse_har_version  ( -- riksintressens tidigare versioner
    datum TIMESTAMP NOT NULL DEFAULT clock_timestamp(),

    riksintresse_id INT NOT NULL,
    FOREIGN KEY (riksintresse_id) REFERENCES riksintresse(id),
    anvandare_id INT NOT NULL,
    FOREIGN KEY (anvandare_id) REFERENCES anvandare(id),
    tidigare_version_id INT NOT NULL,
    FOREIGN KEY (tidigare_version_id) REFERENCES tidigare_version(id)
);