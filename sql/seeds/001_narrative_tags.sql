-- Seeds 001: Narrative Tags for Kohärenz Protokoll
-- 80-120 narrative tags with hierarchical structure

BEGIN;

-- Root categories
INSERT INTO tags (slug, title, description, kind, meta) VALUES
('genre', 'Genre', 'Übergeordnete Kategorie für Genreelemente', 'narrative', '{"category": "root"}'),
('tone', 'Tone', 'Übergeordnete Kategorie für Tonalität und Stimmung', 'narrative', '{"category": "root"}'),
('pacing', 'Pacing', 'Übergeordnete Kategorie für Erzählrhythmus und Tempo', 'narrative', '{"category": "root"}'),
('pov', 'Point of View', 'Übergeordnete Kategorie für Erzählperspektive', 'narrative', '{"category": "root"}'),
('character', 'Character', 'Übergeordnete Kategorie für Charakterentwicklung', 'narrative', '{"category": "root"}'),
('plot', 'Plot', 'Übergeordnete Kategorie für Handlungsstruktur', 'narrative', '{"category": "root"}'),
('scene', 'Scene', 'Übergeordnete Kategorie für Szenenfunktion', 'narrative', '{"category": "root"}'),
('conflict', 'Conflict', 'Übergeordnete Kategorie für Konflikte', 'narrative', '{"category": "root"}'),
('theme', 'Theme', 'Übergeordnete Kategorie für Themen', 'narrative', '{"category": "root"}'),
('motif', 'Motif', 'Übergeordnete Kategorie für Motive', 'narrative', '{"category": "root"}'),
('world', 'World', 'Übergeordnete Kategorie für Weltenbau', 'narrative', '{"category": "root"}'),
('continuity', 'Continuity', 'Übergeordnete Kategorie für narrative Kontinuität', 'narrative', '{"category": "root"}'),
('style', 'Style', 'Übergeordnete Kategorie für Erzählstil', 'narrative', '{"category": "root"}');

-- Genre subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('genre.fantasy', 'Fantasy', 'Fantastische Elemente mit übernatürlichen Kräften', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}'),
('genre.scifi', 'Science Fiction', 'Wissenschaftlich basierte spekulative Elemente', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}'),
('genre.mystery', 'Mystery', 'Rätselhafte Ereignisse die aufgeklärt werden müssen', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}'),
('genre.thriller', 'Thriller', 'Spannungsgeladene Szenen mit Gefahr und Bedrohung', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}'),
('genre.romance', 'Romance', 'Romantische Beziehungen als zentrales Element', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}'),
('genre.horror', 'Horror', 'Gruselemente zur Erzeugung von Angst und Schrecken', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}'),
('genre.drama', 'Drama', 'Emotionale Konflikte und menschliche Beziehungen', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}'),
('genre.comedy', 'Comedy', 'Humorvolle Elemente zur Unterhaltung', 'narrative', (SELECT id FROM tags WHERE slug = 'genre'), '{}');

-- Tone subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('tone.dark', 'Dark', 'Düstere, pessimistische oder bedrohliche Stimmung', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}'),
('tone.light', 'Light', 'Heitere, optimistische oder unbeschwerte Stimmung', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}'),
('tone.serious', 'Serious', 'Ernste, gewichtige Behandlung des Themas', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}'),
('tone.satirical', 'Satirical', 'Spöttische oder kritische Darstellung', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}'),
('tone.melancholic', 'Melancholic', 'Schwermütige, nachdenkliche Grundstimmung', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}'),
('tone.hopeful', 'Hopeful', 'Hoffnungsvolle, zuversichtliche Grundhaltung', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}'),
('tone.nostalgic', 'Nostalgic', 'Sehnsucht nach vergangenen Zeiten', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}'),
('tone.mysterious', 'Mysterious', 'Geheimnisvolle, rätselhafte Atmosphäre', 'narrative', (SELECT id FROM tags WHERE slug = 'tone'), '{}');

-- Pacing subcategories (Key Navigators with long descriptions)
INSERT INTO tags (slug, title, description, long_description, kind, parent_id, meta) VALUES
('pacing.fast', 'Fast Pacing', 'Schnelle Abfolge von Ereignissen und Wendungen', 'Schnelles Pacing treibt die Handlung voran durch kurze Kapitel, häufige Szenenwechsel und kontinuierliche Action. Es erzeugt Spannung und hält den Leser gefesselt, kann aber bei Übernutzung ermüdend wirken und wichtige Charaktermomente überschatten.', 'narrative', (SELECT id FROM tags WHERE slug = 'pacing'), '{"key_navigator": true}'),
('pacing.slow', 'Slow Pacing', 'Bedächtige Entwicklung mit Zeit für Reflexion', 'Langsames Pacing erlaubt tiefere Charakterentwicklung und atmosphärische Beschreibungen. Es gibt dem Leser Zeit zum Nachdenken und Verstehen, kann aber bei Übertreibung zu Langeweile führen und die narrative Spannung schwächen.', 'narrative', (SELECT id FROM tags WHERE slug = 'pacing'), '{"key_navigator": true}'),
('pacing.varied', 'Varied Pacing', 'Wechsel zwischen schnellen und langsamen Passagen', 'Variiertes Pacing kombiniert Momente der Intensität mit ruhigeren Phasen der Reflexion. Dies schafft einen natürlichen Rhythmus, der sowohl Spannung als auch emotionale Tiefe ermöglicht und dem Leser Atempausen gewährt.', 'narrative', (SELECT id FROM tags WHERE slug = 'pacing'), '{"key_navigator": true}'),
('pacing.build', 'Building Tension', 'Allmähliche Steigerung der Spannung', 'Spannungsaufbau erfolgt durch schrittweise Enthüllung von Informationen und eskalierende Konflikte. Diese Technik hält das Interesse aufrecht und führt zu kraftvollen Höhepunkten, erfordert aber geschickte Balance zwischen Enthüllung und Zurückhaltung.', 'narrative', (SELECT id FROM tags WHERE slug = 'pacing'), '{"key_navigator": true}');

-- POV subcategories (Key Navigators)
INSERT INTO tags (slug, title, description, long_description, kind, parent_id, meta) VALUES
('pov.first', 'First Person', 'Erzählung aus der Ich-Perspektive', 'Die Ich-Erzählung schafft unmittelbare Nähe zum Protagonisten und erlaubt tiefe Einblicke in Gedanken und Gefühle. Sie begrenzt jedoch das Wissen auf eine Perspektive und kann bei komplexen Handlungen einschränkend wirken. Besonders effektiv für charaktergetriebene Geschichten.', 'narrative', (SELECT id FROM tags WHERE slug = 'pov'), '{"key_navigator": true}'),
('pov.third_limited', 'Third Person Limited', 'Begrenzte Allwissende Erzählperspektive', 'Die begrenzte Dritte Person kombiniert emotionale Nähe mit narrativer Flexibilität. Sie folgt meist einem Charakter pro Szene, erlaubt aber Perspektivwechsel zwischen Kapiteln. Diese Technik bietet Ausgewogenheit zwischen Intimität und erzählerischer Freiheit.', 'narrative', (SELECT id FROM tags WHERE slug = 'pov'), '{"key_navigator": true}'),
('pov.third_omniscient', 'Third Person Omniscient', 'Allwissende Erzählperspektive', 'Der allwissende Erzähler kennt Gedanken und Gefühle aller Charaktere sowie zukünftige Ereignisse. Dies ermöglicht komplexe, vielschichtige Erzählungen, kann aber emotionale Distanz schaffen und erfordert geschickte Handhabung, um nicht überwältigend zu wirken.', 'narrative', (SELECT id FROM tags WHERE slug = 'pov'), '{"key_navigator": true}'),
('pov.multiple', 'Multiple POV', 'Wechselnde Erzählperspektiven', 'Multiple Perspektiven bieten verschiedene Sichtweisen auf Ereignisse und vertiefen das Verständnis komplexer Situationen. Sie erfordern jedoch klare Übergänge und einzigartige Charakterstimmen, um Verwirrung zu vermeiden und jede Perspektive wertvoll zu machen.', 'narrative', (SELECT id FROM tags WHERE slug = 'pov'), '{"key_navigator": true}');

-- Character Arc subcategories (Key Navigators)
INSERT INTO tags (slug, title, description, long_description, kind, parent_id, meta) VALUES
('character.arc', 'Character Arc', 'Übergeordnete Kategorie für Charakterentwicklung', 'Charakterbögen beschreiben die innere Reise einer Figur durch die Geschichte', 'narrative', (SELECT id FROM tags WHERE slug = 'character'), '{}'),
('character.arc.growth', 'Growth Arc', 'Positive Charakterentwicklung und Reifung', 'Ein Wachstumsbogen zeigt, wie ein Charakter Schwächen überwindet und zu einer besseren Version seiner selbst wird. Diese Transformation sollte organisch aus den Herausforderungen der Geschichte entstehen und durch konkrete Handlungen demonstriert werden, nicht nur durch Worte erklärt.', 'narrative', (SELECT id FROM tags WHERE slug = 'character.arc'), '{"key_navigator": true}'),
('character.arc.fall', 'Fall Arc', 'Negative Charakterentwicklung oder Tragödie', 'Ein Fallbogen dokumentiert den moralischen oder persönlichen Abstieg eines Charakters. Diese tragische Entwicklung sollte nachvollziehbar motiviert sein und als Warnung oder Lehre dienen, während sie gleichzeitig emotionale Resonanz beim Leser erzeugt.', 'narrative', (SELECT id FROM tags WHERE slug = 'character.arc'), '{"key_navigator": true}'),
('character.arc.flat', 'Flat Arc', 'Charakter bleibt konstant und beeinflusst andere', 'Ein flacher Bogen bedeutet nicht mangelnde Entwicklung, sondern dass der Charakter bereits starke Werte besitzt und andere verändert. Diese Charaktere dienen oft als moralische Anker und Katalysatoren für die Entwicklung anderer Figuren in der Geschichte.', 'narrative', (SELECT id FROM tags WHERE slug = 'character.arc'), '{"key_navigator": true}');

-- Plot subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('plot.setup', 'Setup', 'Einführung der Welt, Charaktere und Konflikte', 'narrative', (SELECT id FROM tags WHERE slug = 'plot'), '{}'),
('plot.inciting', 'Inciting Incident', 'Auslösendes Ereignis das die Handlung in Gang setzt', 'narrative', (SELECT id FROM tags WHERE slug = 'plot'), '{}'),
('plot.rising', 'Rising Action', 'Steigende Handlung mit zunehmenden Komplikationen', 'narrative', (SELECT id FROM tags WHERE slug = 'plot'), '{}'),
('plot.climax', 'Climax', 'Höhepunkt der Geschichte und Konfliktlösung', 'narrative', (SELECT id FROM tags WHERE slug = 'plot'), '{}'),
('plot.falling', 'Falling Action', 'Fallende Handlung nach dem Höhepunkt', 'narrative', (SELECT id FROM tags WHERE slug = 'plot'), '{}'),
('plot.resolution', 'Resolution', 'Auflösung der Geschichte und aller Handlungsstränge', 'narrative', (SELECT id FROM tags WHERE slug = 'plot'), '{}'),
('plot.twist', 'Plot Twist', 'Unerwartete Wendung die Annahmen umkehrt', 'Eine Plotwendung überrascht den Leser durch die Enthüllung neuer Informationen, die bisherige Annahmen über Charaktere oder Ereignisse fundamental verändern. Effektive Wendungen sind rückblickend logisch nachvollziehbar, aber in der ersten Lektüre überraschend. Sie sollten die Geschichte voranbringen, nicht nur schockieren.', 'narrative', (SELECT id FROM tags WHERE slug = 'plot'), '{"key_navigator": true}');

-- Scene Function subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('scene.function', 'Scene Function', 'Übergeordnete Kategorie für Szenenfunktionen', 'narrative', (SELECT id FROM tags WHERE slug = 'scene'), '{}'),
('scene.function.action', 'Action Scene', 'Szene mit physischer Aktivität und Bewegung', 'narrative', (SELECT id FROM tags WHERE slug = 'scene.function'), '{}'),
('scene.function.dialogue', 'Dialogue Scene', 'Szene fokussiert auf Charakterinteraktion durch Gespräche', 'narrative', (SELECT id FROM tags WHERE slug = 'scene.function'), '{}'),
('scene.function.exposition', 'Exposition Scene', 'Szene zur Informationsvermittlung und Welterklärung', 'narrative', (SELECT id FROM tags WHERE slug = 'scene.function'), '{}'),
('scene.function.reflection', 'Reflection Scene', 'Szene für innere Gedanken und Charakterentwicklung', 'narrative', (SELECT id FROM tags WHERE slug = 'scene.function'), '{}'),
('scene.function.transition', 'Transition Scene', 'Verbindungsszene zwischen wichtigen Ereignissen', 'narrative', (SELECT id FROM tags WHERE slug = 'scene.function'), '{}');

-- Conflict subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('conflict.internal', 'Internal Conflict', 'Innere Kämpfe und persönliche Dilemmata', 'narrative', (SELECT id FROM tags WHERE slug = 'conflict'), '{}'),
('conflict.interpersonal', 'Interpersonal Conflict', 'Konflikte zwischen Charakteren', 'narrative', (SELECT id FROM tags WHERE slug = 'conflict'), '{}'),
('conflict.societal', 'Societal Conflict', 'Konflikte mit gesellschaftlichen Strukturen', 'narrative', (SELECT id FROM tags WHERE slug = 'conflict'), '{}'),
('conflict.environmental', 'Environmental Conflict', 'Konflikte mit natürlichen oder physischen Hindernissen', 'narrative', (SELECT id FROM tags WHERE slug = 'conflict'), '{}'),
('conflict.supernatural', 'Supernatural Conflict', 'Konflikte mit übernatürlichen Kräften', 'narrative', (SELECT id FROM tags WHERE slug = 'conflict'), '{}');

-- Theme subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('theme.love', 'Love', 'Verschiedene Formen der Liebe und Zuneigung', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}'),
('theme.power', 'Power', 'Macht, Kontrolle und deren Missbrauch', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}'),
('theme.identity', 'Identity', 'Selbstfindung und persönliche Identität', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}'),
('theme.sacrifice', 'Sacrifice', 'Opferbereitschaft und deren Konsequenzen', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}'),
('theme.redemption', 'Redemption', 'Erlösung und zweite Chancen', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}'),
('theme.justice', 'Justice', 'Gerechtigkeit, Moral und ethische Entscheidungen', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}'),
('theme.freedom', 'Freedom', 'Freiheit versus Sicherheit und Kontrolle', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}'),
('theme.betrayal', 'Betrayal', 'Verrat und gebrochenes Vertrauen', 'narrative', (SELECT id FROM tags WHERE slug = 'theme'), '{}');

-- Motif subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('motif.riss', 'Riss', 'Wiederkehrendes Motiv des Bruchs oder der Teilung', 'narrative', (SELECT id FROM tags WHERE slug = 'motif'), '{}'),
('motif.light', 'Light', 'Licht als Symbol für Hoffnung, Wahrheit oder Göttlichkeit', 'narrative', (SELECT id FROM tags WHERE slug = 'motif'), '{}'),
('motif.shadow', 'Shadow', 'Schatten als Symbol für Geheimnis, Gefahr oder das Unbewusste', 'narrative', (SELECT id FROM tags WHERE slug = 'motif'), '{}'),
('motif.journey', 'Journey', 'Reise als Metapher für persönliche Entwicklung', 'narrative', (SELECT id FROM tags WHERE slug = 'motif'), '{}'),
('motif.mask', 'Mask', 'Maske als Symbol für verborgene Identität oder Täuschung', 'narrative', (SELECT id FROM tags WHERE slug = 'motif'), '{}'),
('motif.mirror', 'Mirror', 'Spiegel als Symbol für Selbstreflexion oder Dualität', 'narrative', (SELECT id FROM tags WHERE slug = 'motif'), '{}');

-- World Anchors (Key Navigators)
INSERT INTO tags (slug, title, description, long_description, kind, parent_id, meta) VALUES
('world.anchor', 'World Anchors', 'Übergeordnete Kategorie für Weltanker', 'Weltanker definieren zentrale Elemente der erzählten Welt', 'narrative', (SELECT id FROM tags WHERE slug = 'world'), '{}'),
('world.anchor.w1', 'World Anchor W1', 'Primärer Weltanker - fundamentale Realitätsregeln', 'W1 definiert die grundlegenden physikalischen und metaphysischen Gesetze der Welt. Diese Regeln bestimmen, was möglich ist und was nicht, von Naturgesetzen bis zu magischen Systemen. Konsistenz in W1 ist entscheidend für die Glaubwürdigkeit der Geschichte und das Vertrauen der Leser.', 'narrative', (SELECT id FROM tags WHERE slug = 'world.anchor'), '{"key_navigator": true, "anchor_level": "W1"}'),
('world.anchor.w2', 'World Anchor W2', 'Sekundärer Weltanker - gesellschaftliche Strukturen', 'W2 umfasst soziale, politische und kulturelle Systeme der Welt. Hier werden Gesellschaftsformen, Machtstrukturen, Traditionen und Normen definiert, die das Verhalten der Charaktere prägen und Konflikte ermöglichen. Diese Strukturen sollten logisch aus W1 folgen.', 'narrative', (SELECT id FROM tags WHERE slug = 'world.anchor'), '{"key_navigator": true, "anchor_level": "W2"}'),
('world.anchor.w3', 'World Anchor W3', 'Tertiärer Weltanker - lokale Besonderheiten', 'W3 beschreibt spezifische Orte, Regionen oder Gruppen mit besonderen Eigenschaften. Diese lokalen Variationen bereichern die Welt und bieten Möglichkeiten für diverse Settings und Konflikte, sollten aber nicht den übergeordneten Weltankern W1 und W2 widersprechen.', 'narrative', (SELECT id FROM tags WHERE slug = 'world.anchor'), '{"key_navigator": true, "anchor_level": "W3"}'),
('world.anchor.w4', 'World Anchor W4', 'World Anchor W4', 'Quaternärer Weltanker - individuelle Anomalien', 'W4 erfasst einzigartige Phänomene, Artefakte oder Individuen mit außergewöhnlichen Eigenschaften. Diese Elemente können Plotwendungen ermöglichen, sollten aber sparsam eingesetzt werden und eine nachvollziehbare Verbindung zu den etablierten Weltregeln haben.', 'narrative', (SELECT id FROM tags WHERE slug = 'world.anchor'), '{"key_navigator": true, "anchor_level": "W4"}');

-- Continuity Anchor (Key Navigator)
INSERT INTO tags (slug, title, description, long_description, kind, parent_id, meta) VALUES
('continuity.anchor', 'Continuity Anchor', 'Narrative Kontinuität und Konsistenz', 'Der Kontinuitätsanker gewährleistet die innere Logik und Konsistenz der Geschichte über alle Handlungsstränge hinweg. Er überwacht Charakterentwicklung, Zeitlinien, etablierte Regeln und bereits getroffene Aussagen. Verstöße gegen die Kontinuität können das Vertrauen der Leser erschüttern und die Immersion zerstören.', 'narrative', (SELECT id FROM tags WHERE slug = 'continuity'), '{"key_navigator": true}');

-- Style subcategories
INSERT INTO tags (slug, title, description, kind, parent_id, meta) VALUES
('style.show_dont_tell', 'Show Don\'t Tell', 'Informationen durch Handlung statt Erklärung vermitteln', 'narrative', (SELECT id FROM tags WHERE slug = 'style'), '{}'),
('style.dialogue', 'Dialogue Heavy', 'Geschichten mit starkem Fokus auf Dialoge', 'narrative', (SELECT id FROM tags WHERE slug = 'style'), '{}'),
('style.descriptive', 'Descriptive', 'Ausführliche Beschreibungen von Orten und Atmosphäre', 'narrative', (SELECT id FROM tags WHERE slug = 'style'), '{}'),
('style.minimalist', 'Minimalist', 'Reduzierte Sprache mit Fokus auf das Wesentliche', 'narrative', (SELECT id FROM tags WHERE slug = 'style'), '{}'),
('style.experimental', 'Experimental', 'Unkonventionelle Erzähltechniken und Strukturen', 'narrative', (SELECT id FROM tags WHERE slug = 'style'), '{}'),
('style.stream_consciousness', 'Stream of Consciousness', 'Direkter Zugang zu Gedankenströmen der Charaktere', 'narrative', (SELECT id FROM tags WHERE slug = 'style'), '{}');

COMMIT;
