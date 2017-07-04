xquery version "1.0" encoding "UTF-8";

(: paste the result of step 1 into the variable below to generate the register :)

declare namespace loop="http://kb.dk/this/getlist";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";

declare namespace local="http://kb.dk/this/app";
declare namespace m="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/html"; 

declare variable $database := "/db/dcm";
declare variable $collection := request:get-parameter("c","");

declare variable $names := 
       <div xmlns="http://www.music-encoding.org/ns/mei" id="names">
    <persName>Magda &amp; Vilhelm Herold</persName>
    <persName>Lucas 11</persName>
    <persName>Herrekoret A. F. K.</persName>
    <persName>C. A.</persName>
    <persName>Oversergent A.C. Petersen</persName>
    <persName>Emil Aarestrup</persName>
    <persName>Ida Adams</persName>
    <persName>Johan Adolf Gottlob Stage</persName>
    <persName>Hans Adolph Brorson</persName>
    <persName>Hans Albertsen</persName>
    <persName>H. Albrecht</persName>
    <persName>T. Albrecht</persName>
    <persName>Robert Allen</persName>
    <persName>Emma Allerup</persName>
    <persName>Arthur Allin</persName>
    <persName>H.C. Andersen after Carlo Gozzi's "Il Corvo"</persName>
    <persName>Anna Andersen</persName>
    <persName>Carl Andersen</persName>
    <persName>F. Andersen</persName>
    <persName>H.C. Andersen</persName>
    <persName>Henriette Andersen</persName>
    <persName>Jacobine Andersen</persName>
    <persName>Joachim Andersen</persName>
    <persName>Robert Anderson</persName>
    <persName>Elfrida Andrée</persName>
    <persName>Anonymous</persName>
    <persName>Kristian Arentzen</persName>
    <persName>Oscar Arpi</persName>
    <persName>Agnes Attrup</persName>
    <persName>Carl Attrup</persName>
    <persName>Berthold Auerbach</persName>
    <persName>Frederik August Hartmann &amp; Alice Hartmann</persName>
    <persName>Frederik August Hartmann and Alice Hartmann</persName>
    <persName>Georg Bachmann</persName>
    <persName>Jens Baggesen</persName>
    <persName>Frederik Barfod after "Den Danske Riimkrønike"</persName>
    <persName>Frederik Barfod</persName>
    <persName>Christian Barnekow</persName>
    <persName>Johan Bartholdy</persName>
    <persName>Sophus Bauditz</persName>
    <persName>F. Becker</persName>
    <persName>William Behrend</persName>
    <persName>Frederikke Berg</persName>
    <persName>Michael Berg</persName>
    <persName>A.P. Berggreen</persName>
    <persName>Julius Bergmann</persName>
    <persName>Vilhelmine Bergnehr</persName>
    <persName>Ludvig Bernhard Sahlgreen</persName>
    <persName>Ida Berthelsen</persName>
    <persName>Viggo Bielefeld</persName>
    <persName>Viggo Bielefeldt</persName>
    <persName>Vilhelm Birkedal</persName>
    <persName>Bjørnstjerne Bjørnson</persName>
    <persName>G.C. Bohlmann</persName>
    <persName>Knud Bokkenheuser</persName>
    <persName>N. Borck</persName>
    <persName>Carl Borgaard</persName>
    <persName>Johan Borup</persName>
    <persName>August Bournonville</persName>
    <persName>Charlotte Bournonville</persName>
    <persName>Margrethe Boye</persName>
    <persName>C.J. Brandt</persName>
    <persName>Ivar Bredal</persName>
    <persName>Iver Bredal</persName>
    <persName>Magnus Brostrup Landstad after Laurenthius Petri Gothus</persName>
    <persName>Magnus Brostrup Landstad</persName>
    <persName>Frederik Brun</persName>
    <persName>Jfr. Bruus</persName>
    <persName>Otta Brønnum</persName>
    <persName>Otto Brønnum</persName>
    <persName>Leopold Budde</persName>
    <persName>F. Burmeister</persName>
    <persName>Chr. Bygum</persName>
    <persName>William Bähncke</persName>
    <persName>Nicolai Bøgh</persName>
    <persName>V. C. Holm</persName>
    <persName>Friedrich Caspari</persName>
    <persName>Birgitte Cathrine Boye</persName>
    <persName>Frederik Cetti</persName>
    <persName>H. Chr. Sthen</persName>
    <persName>Julius Christian Gerson</persName>
    <persName>Johann Christian Haug</persName>
    <persName>Jens Christian Hostrup</persName>
    <persName>Johan Christian Ryge</persName>
    <persName>Einar Christiansen</persName>
    <persName>Eleonore Christine Zrza</persName>
    <persName>Maria Christoffersen</persName>
    <persName>Carl Christoph Jung</persName>
    <persName>H.E. Christophersen</persName>
    <persName>Wilhelm Conrad Holst</persName>
    <persName>C. Cortzen</persName>
    <persName>Bernhard Courländer</persName>
    <persName>Cäciliaforeningen</persName>
    <persName>Til Cæcilia-Foreningen i Kjøbenhavn - Dem Cæcilienverein in Copenhagen</persName>
    <persName>Cæciliaforeningen</persName>
    <persName>Agnes Dahl</persName>
    <persName>Balduin Dahl</persName>
    <persName>Holger Dahl</persName>
    <persName>Waldemar Dahl</persName>
    <persName>Mary Dana Shindler</persName>
    <persName>Ira David Sankey</persName>
    <persName>Ferdinand David</persName>
    <persName>Agnes Dehn</persName>
    <persName>Beatrice Diderichsen</persName>
    <persName>Peter Diderik Ibsen</persName>
    <persName>Elsbeth Donniges</persName>
    <persName>Elisabeth Dons</persName>
    <persName>Jeanne Douste de Fortis</persName>
    <persName>Hr. Dr. Frisch</persName>
    <persName>Holger Drachmann</persName>
    <persName>Sangkorene Dur og Moll</persName>
    <persName>Julius Döcker or Richard Jastrau</persName>
    <persName>Julius Döcker</persName>
    <persName>Julius Døcker or Richard Jastrau</persName>
    <persName>Julius Døcker</persName>
    <persName>Otto Dütsch</persName>
    <persName>Josephine Eckardt</persName>
    <persName>Lauritz Eckardt</persName>
    <persName>Doris Eckhardt Hansen</persName>
    <persName>Harald Edvard Christophersen</persName>
    <persName>Albertine Elberholz</persName>
    <persName>Christian Emil Braunstein</persName>
    <persName>Ambrosius: Emil Poulsen</persName>
    <persName>Doris Erhard-Hansen</persName>
    <persName>Peter Ernst Braase</persName>
    <persName>J. Ernst</persName>
    <persName>Emil Erslev</persName>
    <persName>Johannes Ewald</persName>
    <persName>Rasmus Faaborg</persName>
    <persName>Christian Felix Weisse</persName>
    <persName>Ludvig Ferdinand Sahlertz</persName>
    <persName>Christian Ferslev</persName>
    <persName>Christen Foersom</persName>
    <persName>Danish Folk Song</persName>
    <persName>Julie Fonseca</persName>
    <persName>Axel Foss</persName>
    <persName>Johannes Frederik Frøhlich</persName>
    <persName>Johan Frederik Kirchheiner</persName>
    <persName>Andreas Frederik Lincke</persName>
    <persName>King Frederik VII</persName>
    <persName>P. Frederiksen</persName>
    <persName>Johan Fredrik Berwald</persName>
    <persName>Johan Friderichsen</persName>
    <persName>C.T. Friis-Holm</persName>
    <persName>Vor Frue Kirkes Chor</persName>
    <persName>Vor Frue Menighed i Kjøbenhavn</persName>
    <persName>Frydenlund</persName>
    <persName>J.F. Fröhlich</persName>
    <persName>Jørgen Fuglebæk</persName>
    <persName>Hr. Funck</persName>
    <persName>P. Funck</persName>
    <persName>Peter Funck</persName>
    <persName>Sophie Gade</persName>
    <persName>Christian Geisler</persName>
    <persName>C.L. Gerlach</persName>
    <persName>Agnes Giersing</persName>
    <persName>Pauline Giersing</persName>
    <persName>Agnes Gjørling</persName>
    <persName>Glass</persName>
    <persName>Franz Glæser</persName>
    <persName>Peder Gram</persName>
    <persName>Axel Grandjean</persName>
    <persName>Vilhelm Gregersen</persName>
    <persName>N.F.S. Grundtvig after Saxo</persName>
    <persName>N.F.S. Grundtvig efter Davids 92. psalme</persName>
    <persName>N.F.S. Grundtvig</persName>
    <persName>Martin Grønlund</persName>
    <persName>Axel Guldbrandsen</persName>
    <persName>Erik Gustaf Geijer</persName>
    <persName>Fanny Gætje</persName>
    <persName>H.S:.Paulli</persName>
    <persName>Ernst Haberbier</persName>
    <persName>Villie Hagbo Petersen</persName>
    <persName>Paul Hagemann</persName>
    <persName>Hansen</persName>
    <persName>Agnes Hansen</persName>
    <persName>B. Hansen</persName>
    <persName>C.J. Hansen</persName>
    <persName>Christian Hansen</persName>
    <persName>Eckhardt Hansen</persName>
    <persName>Erhard Hansen</persName>
    <persName>Erhardine Hansen</persName>
    <persName>F.J. Hansen</persName>
    <persName>Jfr: Hansen</persName>
    <persName>Johanne Hansen</persName>
    <persName>Kofoed Hansen</persName>
    <persName>Nicolai Hansen</persName>
    <persName>Nicolaj Hansen</persName>
    <persName>P. Hansen</persName>
    <persName>Peter Hansen</persName>
    <persName>Robert Hansen</persName>
    <persName>William Hansen</persName>
    <persName>Wolfgang Hansen</persName>
    <persName>Harpf</persName>
    <persName>Hartenberg</persName>
    <persName>Emil Hartmann</persName>
    <persName>Emma Hartmann</persName>
    <persName>J.P.E. Hartmann</persName>
    <persName>Johann Hartmann</persName>
    <persName>Anton Hartvigson</persName>
    <persName>M. Hassenfeldt</persName>
    <persName>Carsten Hauch</persName>
    <persName>Christian Haunstrup</persName>
    <persName>Ivar Hedenblad</persName>
    <persName>Heinrich Heine</persName>
    <persName>August Heinrich Hoffmann von Fallersleben</persName>
    <persName>Johann Heinrich Voss</persName>
    <persName>Peter Heise</persName>
    <persName>Betty Hennings</persName>
    <persName>Roger Henrichsen</persName>
    <persName>Anna Henriette Andersen</persName>
    <persName>Johannes Henrik Sahlertz</persName>
    <persName>Fini Henriques</persName>
    <persName>Adolph Henselt</persName>
    <persName>George Hepworth</persName>
    <persName>Henrik Hertz</persName>
    <persName>Minna Heyn</persName>
    <persName>N.P. Hillebrandt</persName>
    <persName>F.C. Hillerup</persName>
    <persName>Camilla Hilmer</persName>
    <persName>Frk. Hoffmeyer</persName>
    <persName>Augusta Holm</persName>
    <persName>Emil Holm</persName>
    <persName>Ludvig Holm</persName>
    <persName>P. Holm</persName>
    <persName>Johannes Holm-Hansen</persName>
    <persName>Christiane Holst</persName>
    <persName>H.P. Holst</persName>
    <persName>Iver Holter</persName>
    <persName>Horace</persName>
    <persName>Christoffer Hvid</persName>
    <persName>Thomas Hygom ved N.F.S. Grundtvig</persName>
    <persName>Ernst Høeberg</persName>
    <persName>Ibid.</persName>
    <persName>B.S. Ingemann</persName>
    <persName>Probably J.P.E. Hartmann</persName>
    <persName>Sophie Jacobine Winsløw</persName>
    <persName>Ludvig Jastrau</persName>
    <persName>Richard Jastrau</persName>
    <persName>Camilla Jensen</persName>
    <persName>Carl Jensen</persName>
    <persName>H. Jensen</persName>
    <persName>Peter Jerndorff</persName>
    <persName>C.C. Jessen</persName>
    <persName>W. Jessen</persName>
    <persName>Rasmus Johansen Maale</persName>
    <persName>Mrs John P. Morgan</persName>
    <persName>Franz Joseph Glæser</persName>
    <persName>Niels Juel Simonsen</persName>
    <persName>Niels Juel-Simonsen</persName>
    <persName>Julie</persName>
    <persName>Theodor Julius Liebe</persName>
    <persName>Carl Julius Rongsted</persName>
    <persName>C.A.C. Jung</persName>
    <persName>Christian Juul</persName>
    <persName>Emil Jæhnigen</persName>
    <persName>Viggo Jæhnigen</persName>
    <persName>Anna Jørgensen</persName>
    <persName>Henriette Jørgensen</persName>
    <persName>Olivia Jørgensen</persName>
    <persName>C. Jürs</persName>
    <persName>Chr. K.F. Molbech</persName>
    <persName>Johannes Kabell</persName>
    <persName>Sophie Keller</persName>
    <persName>Thomas Kingo</persName>
    <persName>Karl Knopp</persName>
    <persName>Adolf Knudsen</persName>
    <persName>E.A Koch</persName>
    <persName>Thyra Kock</persName>
    <persName>Valdemar Kolling</persName>
    <persName>Niels Krabbe</persName>
    <persName>Christian Kragh</persName>
    <persName>Sigrid Kreyenberg</persName>
    <persName>Augusta Købke</persName>
    <persName>Hr. Kølle</persName>
    <persName>A. Lange</persName>
    <persName>Thor Lange</persName>
    <persName>P.E. Lange-Müller</persName>
    <persName>Adolf Langsted</persName>
    <persName>A.W. Lanzky</persName>
    <persName>Frederikke Larcher</persName>
    <persName>Louise Larcher</persName>
    <persName>Jens Larsen Nyrop</persName>
    <persName>Alexander Larsen</persName>
    <persName>Alfred Larsen</persName>
    <persName>Klokker Larsen</persName>
    <persName>Caroline Lehmann</persName>
    <persName>V. Lehmann</persName>
    <persName>Kammerherre Lehnsgreve C.A. Lerche Lerchenborg</persName>
    <persName>G.A. Lembcke</persName>
    <persName>Jfr. Levin</persName>
    <persName>Jfr: Levin</persName>
    <persName>Hr. Levinsen</persName>
    <persName>Anna Levinsohn</persName>
    <persName>Salomon Levysohn</persName>
    <persName>Erika Lie</persName>
    <persName>Emilie Liebe</persName>
    <persName>Theodor Liebe</persName>
    <persName>F.L. Liebenberg</persName>
    <persName>Ida Liebert</persName>
    <persName>Axel Liebmann or Victor E. Bendix</persName>
    <persName>August Liebmann</persName>
    <persName>Axel Liebmann</persName>
    <persName>J. Lindahl</persName>
    <persName>Lindberg</persName>
    <persName>Franz Liszt</persName>
    <persName>Edmund Lobedanz</persName>
    <persName>Johan Ludvig Engström</persName>
    <persName>Johan Ludvig Heiberg</persName>
    <persName>Johan Ludvig Schneider</persName>
    <persName>Johann Ludwig Wilhelm Gleim</persName>
    <persName>Johanne Luise Heiberg</persName>
    <persName>Chr. Lund</persName>
    <persName>Christian Lund</persName>
    <persName>H. Lund</persName>
    <persName>J. Lund</persName>
    <persName>Josephine Lund</persName>
    <persName>Sigurd Lund</persName>
    <persName>Sven Lunn</persName>
    <persName>After Luther</persName>
    <persName>Martin Luther</persName>
    <persName>Augusta Lütken</persName>
    <persName>Cæcilia-Foreningens Madrigalkor</persName>
    <persName>Cæciliaforeningens Madrigalkor</persName>
    <persName>Frederikke Madsen</persName>
    <persName>G. Madsen</persName>
    <persName>Georgenius Madsen</persName>
    <persName>Otto Malling</persName>
    <persName>Jfr. Marker</persName>
    <persName>Heinrich Marschner</persName>
    <persName>Just Mathias Thiele</persName>
    <persName>St. Matthew 1:20-21</persName>
    <persName>G. Matthison-Hansen</persName>
    <persName>Gottfred Matthison-Hansen</persName>
    <persName>Hans Matthison-Hansen</persName>
    <persName>Felix Mendelssohn Bartholdy</persName>
    <persName>Ludwig Mendelssohn</persName>
    <persName>A. Meyer</persName>
    <persName>Albert Meyer</persName>
    <persName>Elisabeth Meyer</persName>
    <persName>Carl Michael Bellman</persName>
    <persName>Sextus Miskow</persName>
    <persName>Andreas Munch</persName>
    <persName>Hr. Musikdirektør Bergmann</persName>
    <persName>Eduard Mörike</persName>
    <persName>C.C. Møller</persName>
    <persName>P.L. Møller</persName>
    <persName>Organist Mønsted</persName>
    <persName>A. Müller</persName>
    <persName>Wilhelm Müller</persName>
    <persName>Adolph Nathan</persName>
    <persName>Ludvig Nathan</persName>
    <persName>J.H. Nebelong</persName>
    <persName>Franz Neruda</persName>
    <persName>Carl Nicolai Sichlau</persName>
    <persName>Philipp Nicolai</persName>
    <persName>Anna Nielsen</persName>
    <persName>C.W. Nielsen</persName>
    <persName>E. Nielsen</persName>
    <persName>Marie Nielsen</persName>
    <persName>N.P. Nielsen</persName>
    <persName>Oda Nielsen</persName>
    <persName>Poul Nielsen</persName>
    <persName>Regina Nielsen</persName>
    <persName>Sophus Nielsen</persName>
    <persName>David Noack</persName>
    <persName>H.H. Nyegaard</persName>
    <persName>Frk. Nyeland</persName>
    <persName>Agnes Nyrop</persName>
    <persName>Jens Nyrop</persName>
    <persName>Adam Oehlenschläger</persName>
    <persName>Cathrine Olrik</persName>
    <persName>E. Olsen</persName>
    <persName>Hr. Olsen</persName>
    <persName>N.P. Olsen</persName>
    <persName>Sophie Olsen</persName>
    <persName>Amelia Opie</persName>
    <persName>Bianca Orsini</persName>
    <persName>Hr. Oscar</persName>
    <persName>Instrumentator: Otto Malling</persName>
    <persName>Thomas Overskou</persName>
    <persName>Mrs P. Morgan</persName>
    <persName>Fr. Paludan-Müller</persName>
    <persName>H.S. Paulli</persName>
    <persName>Jakob Paulli</persName>
    <persName>H.S. Paullii</persName>
    <persName>Cl. Pavels</persName>
    <persName>Benjamin Pedersen</persName>
    <persName>Johan Peter Hartmann</persName>
    <persName>Niels Peter Jensen</persName>
    <persName>N.P. Petersen Dybdahl</persName>
    <persName>Cornelius Petersen [Peter Cornelius]</persName>
    <persName>H. Petersen</persName>
    <persName>L. Petersen</persName>
    <persName>N.P. Petersen</persName>
    <persName>Sophus Petersen</persName>
    <persName>Doris Pfeil</persName>
    <persName>Herr Pfuhle</persName>
    <persName>Charlotte Phister</persName>
    <persName>Louise Phister</persName>
    <persName>Ludvig Phister</persName>
    <persName>Johanna Plockross Pohly</persName>
    <persName>Carl Ploug</persName>
    <persName>Emil Poulsen</persName>
    <persName>Olaf Poulsen</persName>
    <persName>Ferdinand Raimund</persName>
    <persName>Frk. Ravn</persName>
    <persName>A. Ravnkilde</persName>
    <persName>Christian Ravnkilde</persName>
    <persName>Niels Ravnkilde</persName>
    <persName>Carl Reinecke</persName>
    <persName>August Reinhard</persName>
    <persName>Elith Reumert</persName>
    <persName>Chirstian Richardt</persName>
    <persName>Christian Richardt</persName>
    <persName>From Rimkrøniken</persName>
    <persName>Emil Rittershaus</persName>
    <persName>O.P. Ritto</persName>
    <persName>H. Rorup</persName>
    <persName>Adolf Rosenkilde</persName>
    <persName>Anna Rosenkilde</persName>
    <persName>C.N. Rosenkilde</persName>
    <persName>Michael Rosing</persName>
    <persName>P.C. Rothe</persName>
    <persName>Claude Rouget de l'Isle</persName>
    <persName>Louise Rudolfine Sahlgreen</persName>
    <persName>Johan Rudolph Waltz</persName>
    <persName>Sophie Rung Keller</persName>
    <persName>Frederik Rung</persName>
    <persName>Henrik Rung</persName>
    <persName>Pauline Rung</persName>
    <persName>Sophie Rung-Keller</persName>
    <persName>Olaf Rye Poulsen</persName>
    <persName>Nathalia Ryge Constance</persName>
    <persName>J.C. Ryge</persName>
    <persName>Natalia Ryge</persName>
    <persName>Anton Rée</persName>
    <persName>Amanda Röntgen</persName>
    <persName>Julius Röntgen</persName>
    <persName>Louise Sahlgreen</persName>
    <persName>Ludvig Sahlgreen</persName>
    <persName>N. Salomon</persName>
    <persName>Viggo Sanne</persName>
    <persName>Claus Schall</persName>
    <persName>Theodor Scheibel</persName>
    <persName>Christian Schiørring</persName>
    <persName>Jens Schjørring</persName>
    <persName>Betty Schnell</persName>
    <persName>Ingeborg Schourup</persName>
    <persName>Julie Schow</persName>
    <persName>Peter Schram</persName>
    <persName>Clara Schumann</persName>
    <persName>Julius Schwartzen</persName>
    <persName>Anna Schønberg</persName>
    <persName>Gottlieb Siesbye</persName>
    <persName>H.Cpr. Simonsen</persName>
    <persName>Den Skandinaviske Sangforening</persName>
    <persName>Henry Skjær</persName>
    <persName>Studentersangforeningens Soloqvartet</persName>
    <persName>Anna Sophia Franciska Haack</persName>
    <persName>Jacobine Sophie Winsløw</persName>
    <persName>Louis Spohr</persName>
    <persName>Marianne Spohr</persName>
    <persName>Julius Steenberg</persName>
    <persName>Steen Steensen Blicher</persName>
    <persName>Frk. Steinhauer</persName>
    <persName>H.Chr. Sthen</persName>
    <persName>Ambrosius Stub</persName>
    <persName>Studenter-Sangforeningen</persName>
    <persName>Carl Stör</persName>
    <persName>Anton Svendsen</persName>
    <persName>Johan Svendsen</persName>
    <persName>Julie Sødring</persName>
    <persName>Thomas Thaarup</persName>
    <persName>Wilhelm Theodor Albrecht</persName>
    <persName>Magdalene Thoresen</persName>
    <persName>Aage Thygesen</persName>
    <persName>H.A. Timm</persName>
    <persName>Carl Tolderlund</persName>
    <persName>Otto Tolderlund</persName>
    <persName>C. Tolstrup</persName>
    <persName>Wilhelm Traugott Naumann</persName>
    <persName>Marie Tuxen</persName>
    <persName>L.C. Tørsleff</persName>
    <persName>Unknown</persName>
    <persName>Barner Upo</persName>
    <persName>C. V. Møller</persName>
    <persName>Velle Vellesen</persName>
    <persName>Verdier</persName>
    <persName>Niels Viggo Bentzon</persName>
    <persName>Alexandre Vinet</persName>
    <persName>J.N. Vogel</persName>
    <persName>Karen Volquartz</persName>
    <persName>Niels W. Gade or J.P.E. Hartmann</persName>
    <persName>Niels W. Gade</persName>
    <persName>Wilhelm Wackernagel</persName>
    <persName>Axel Waldemar Lanzky</persName>
    <persName>Anna Wexschall</persName>
    <persName>Waage Weyse Matthison-Hansen</persName>
    <persName>Poul Wiedemann</persName>
    <persName>Johannes Wiehe</persName>
    <persName>Michael Wiehe</persName>
    <persName>Wilhelm Wiehe</persName>
    <persName>Adolph Wilhelm Schack von Staffeldt</persName>
    <persName>August Winding and Anton Svendsen</persName>
    <persName>August Winding and Axel Gade</persName>
    <persName>August Winding</persName>
    <persName>Juliane Winsløw</persName>
    <persName>Sophie Winsløw</persName>
    <persName>Christian Winther</persName>
    <persName>Nicolai Wolf</persName>
    <persName>Johann Wolfgang von Goethe</persName>
    <persName>Anna Wroblewsky</persName>
    <persName>Ydun</persName>
    <persName>Christian Zangenberg</persName>
    <persName>Martin Zangenberg</persName>
    <persName>August Zinck</persName>
    <persName>Josephine Zinck</persName>
    <persName>Ludvig Zinck</persName>
    <persName>Heinrich Zschalig</persName>
    <persName>Jalal ad-Din Muhammad Rumi</persName>
    <persName>Jalal ad-Din Muhammad Rumi.</persName>
    <persName>Clara and Emma Hartmann</persName>
    <persName>Hegner and Michelsen</persName>
    <persName>Singer and pianist unknown</persName>
    <persName>Ida da Fonseca</persName>
    <persName>Julie da Fonseca</persName>
    <persName>C. de Lichtenberg</persName>
    <persName>Alfred de Musset</persName>
    <persName>Viggo de Neergaard</persName>
    <persName>Danish folk song adapted by Johan Ludvig Heiberg</persName>
    <persName>Danish folk song adapted by Sven Grundtvig</persName>
    <persName>Danish folk song</persName>
    <persName>Greek folk song</persName>
    <persName>Poem from the Poetic Edda</persName>
    <persName>Poem from the early 17th century</persName>
    <persName>Old hymn after the German</persName>
    <persName>Studentersangforeningen i Lund</persName>
    <persName>Danish medieval ballad</persName>
    <persName>Book of Psalms 115:17-18</persName>
    <persName>Julie or Ida da Fonseca</persName>
    <persName>Danish rhymed prayer</persName>
    <persName>Music teacher Friis</persName>
    <persName>Last two stanzas of the thirteenth-century sequence Stabat Mater</persName>
    <persName>unknown</persName>
    <persName>Singer unknown</persName>
    <persName>Singer unknown.</persName>
    <persName>Rimkrøniken ved C.J. Brandt</persName>
    <persName>Julius von Bernuth</persName>
    <persName>Friedrich von Bodenstedt</persName>
    <persName>Hans von Bülow</persName>
    <persName>Joseph von Eichendorff</persName>
    <persName>Adolph von Gähler</persName>
    <persName>August von Kotzebue</persName>
    <persName>Otto von Königslöw</persName>
    <persName>Rosa von Milde-Agthe</persName>
    <persName>Oscar von Redwitz</persName>
    <persName>Friedrich von Schiller</persName>
    <persName>Wilhelm von Waldbrühl</persName>
    <persName>Ernst von der Recke</persName>
    <persName>Til vor Frue Menighed i Kjøbenhavn</persName>
    <persName>Vilhelmine Østerberg</persName>
    <persName>Wilhelmine Østerberg</persName>
        </div>
;

declare function loop:clean-names ($key as xs:string) as xs:string
{
  (: strip off any text not part of the name (marked with a comma or parentheses) :)
  let $txt := concat(translate(normalize-space($key),',;(','***'),'*')
  return substring-before($txt,'*') 
};

declare function loop:invert-names ($key as xs:string) as xs:string
{
  (: put last name first :)
  let $txt := 
  
  if(contains($key,' ')) then
    concat(normalize-space(substring-after($key,' ')),', ', normalize-space(substring-before($key,' ')))
  else 
    $key 
  return $txt 
};

declare function loop:sort-key ($num as xs:string) as xs:string
{
  let $sort_key:=
      (: make the number a 15 character long string padded with zeros :)
      let $padded_number:=concat("0000000000000000",normalize-space($num))
      let $len:=string-length($padded_number)-14
	return substring($padded_number,$len,15)
  return $sort_key
};

<html xmlns="http://www.w3.org/1999/xhtml">
	<body>

    <h2>Names</h2>
    <!-- Names appearing in <workDesc> or <sourceDesc> only)-->
    <div>
 
		    {
		    
		          if($collection="") then
                    <p>Please choose a file collection/catalogue by adding &apos;?c=[your collection name]&apos; 
                    (for instance, ?c=CNW) to the URL</p>
                  else 
		    
                    for $c in $names/*
            		(: Add exception to above xPath to exclude the composer, e.g. " [not(contains(.,'Carl Nielsen'))]"  :)
                    order by loop:invert-names($c)
            	    return
            		  <div>{concat(loop:invert-names($c),' &#160; ',$collection,' ')} 
            		  {let $numbers :=
            		  for $n in collection($database)/m:mei/m:meiHead[m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"] = $collection]
                         where $n/(m:workDesc | m:fileDesc/m:sourceDesc)//m:persName = $c
                         (: to include only first performances:  where contains($n/(m:workDesc | m:fileDesc/m:sourceDesc)//m:persName[not(local-name(..)='event' and count(../preceding-sibling::m:event)>0)],$c)  :)

                         order by loop:sort-key(string($n/m:workDesc/m:work/m:identifier[@label=$collection])) 
                	     return $n/m:workDesc/m:work/m:identifier[@label=$collection]/string()
                	   return string-join($numbers,', ') 
                   	   } 
                	   </div>

            }
    </div>


  </body>
</html>
