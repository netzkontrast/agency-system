# Prompt Engineering für das Kohärenz Protokoll

## Überblick

Das Kohärenz Protokoll verwendet verschiedene Prompts für die KI-gestützte Verarbeitung von Inhalten. Diese Dokumentation beschreibt die verwendeten Prompt-Muster und Best Practices.

```mermaid
graph TD
    subgraph "Prompt Engineering Pipeline"
        PE[Prompt Engineering]
        
        subgraph "Content Processing Prompts"
            CP1[Question Generation]
            CP2[Answer Generation]
            CP3[Content Parsing]
            CP4[Tagging & Classification]
        end
        
        subgraph "Quality Assurance Prompts"
            QA1[Context Evaluation]
            QA2[Citation Validation]
            QA3[NBA Generation]
            QA4[Response Formatting]
        end
        
        subgraph "Persona-Specific Prompts"
            PS1[Persona Adaptation]
            PS2[Context Switching]
            PS3[Voice Consistency]
            PS4[Domain Expertise]
        end
        
        PE --> CP1
        PE --> CP2
        PE --> CP3
        PE --> CP4
        PE --> QA1
        PE --> QA2
        PE --> QA3
        PE --> QA4
        PE --> PS1
        PE --> PS2
        PE --> PS3
        PE --> PS4
    end
```

## Prompt-Kategorien

### 1. Fragegenerierung (GenQuestionsNode)

**Zweck**: Generierung atomarer Fragen aus Textspans

**Prompt-Muster**:
```
Generiere 3 atomare Fragen aus dem folgenden Textabschnitt:

[TEXT]

Anforderungen:
1. Jede Frage muss präzise und spezifisch sein
2. Jede Frage muss allein mit Informationen aus dem Textabschnitt beantwortbar sein
3. Keine Meta-Fragen (Fragen über den Text)
4. Formuliere in natürlicher Sprache

Gib die Fragen als JSON-Array zurück:
{
  "questions": [
    "Frage 1",
    "Frage 2", 
    "Frage 3"
  ]
}
```

### 2. Antwortgenerierung (GenAnswersNode)

**Zweck**: Generierung von Antworten unterschiedlicher Länge

**Prompt-Muster für kurze Antworten**:
```
Beantworte die folgende Frage kurz und präzise basierend auf dem Kontext:

Frage: [QUESTION]
Kontext: [CONTEXT]

Anforderungen:
- Maximale Länge: 1 Satz
- Fokus auf die wesentliche Information
- Verwende Quellenangaben im Format [1], [2], etc.
```

**Prompt-Muster für mittlere Antworten**:
```
Beantworte die folgende Frage ausführlich basierend auf dem Kontext:

Frage: [QUESTION]
Kontext: [CONTEXT]

Anforderungen:
- Länge: 2-3 Sätze
- Strukturierte Antwort mit klaren Aussagen
- Verwende Quellenangaben im Format [1], [2], etc.
- Jede Aussage muss im Kontext begründet sein
```

**Prompt-Muster für lange Antworten**:
```
Erstelle eine detaillierte Antwort auf die folgende Frage basierend auf dem Kontext:

Frage: [QUESTION]
Kontext: [CONTEXT]

Anforderungen:
- Länge: 5-8 Sätze
- Strukturierte Antwort mit Einleitung, Hauptteil und Zusammenfassung
- Verwende Quellenangaben im Format [1], [2], etc.
- Vertiefe relevante Aspekte mit Erklärungen
```

### 3. Tagging und Kategorisierung

**Zweck**: Semantische Kategorisierung von Inhalten

**Prompt-Muster**:
```
Weise dem folgenden Text semantische Tags zu:

[TEXT]

Anforderungen:
1. Wähle 3-5 relevante Tags
2. Jeder Tag soll ein einzelnes Wort oder eine kurze Phrase sein
3. Tags sollen semantisch bedeutungsvoll sein
4. Vermeide allgemeine oder vage Tags

Gib die Tags als JSON-Array zurück:
{
  "tags": [
    "Tag 1",
    "Tag 2",
    "Tag 3"
  ]
}
```

### 4. Kontextbewertung (Judge)

**Zweck**: Bewertung von Kontexten durch LLM-as-judge

**Prompt-Muster**:
```
Bewerte den folgenden Kontext anhand der angegebenen Kriterien:

Kontext: [CONTEXT]

Kriterien:
1. Kohärenz: Logische Zusammenhänge und Struktur
2. Relevanz: Bezug zur ursprünglichen Frage
3. Vollständigkeit: Abdeckung aller Aspekte
4. Genauigkeit: Korrektheit der Informationen

Anforderungen:
1. Bewerte jedes Kriterium auf einer Skala von 1-5
2. Begründe jede Bewertung kurz
3. Schlage Verbesserungen vor

Gib das Ergebnis als strukturiertes JSON zurück.
```

## Best Practices

```mermaid
flowchart TD
    subgraph "Prompt Design Principles"
        PDP[Prompt Design]
        
        subgraph "Clarity"
            C1[Precise Language]
            C2[Clear Structure]
            C3[Explicit Boundaries]
        end
        
        subgraph "Context Management"
            CM1[Relevant Context]
            CM2[Token Limits]
            CM3[Efficient Representation]
        end
        
        subgraph "Output Structure"
            OS1[Structured Formats]
            OS2[Schema Definition]
            OS3[Validation Rules]
        end
        
        subgraph "Error Handling"
            EH1[Edge Cases]
            EH2[Fallback Mechanisms]
            EH3[Error Recovery]
        end
        
        PDP --> C1
        PDP --> C2
        PDP --> C3
        PDP --> CM1
        PDP --> CM2
        PDP --> CM3
        PDP --> OS1
        PDP --> OS2
        PDP --> OS3
        PDP --> EH1
        PDP --> EH2
        PDP --> EH3
    end
```

### 1. Klare Anweisungen

- Verwende präzise, unmissverständliche Sprache
- Definiere explizit die erwartete Ausgabestruktur
- Setze klare Begrenzungen (Länge, Format, etc.)

### 2. Kontextmanagement

- Stelle sicher, dass der relevante Kontext enthalten ist
- Vermeide Kontextfensterüberschreitung
- Verwende effiziente Kontextrepräsentation

### 3. Strukturierte Ausgaben

- Fordere strukturierte Ausgaben (JSON, YAML) an
- Definiere das Schema explizit
- Implementiere Validierung in den Nodes

### 4. Fehlerbehandlung

- Berücksichtige mögliche Fehlerquellen in den Prompts
- Füge Anweisungen für Edge Cases hinzu
- Plane Fallback-Mechanismen ein

## Prompt-Versionierung

Prompts werden versioniert, um Änderungen nachvollziehen zu können:

```
[KOMPONENTE]_v[VERSION]_[VARIANT]
```

Beispiel: `GenQuestions_v1_atomic`

## Testing

Für jedes Prompt-Muster sollten Testfälle definiert werden:

1. **Positive Tests**: Erwartete Eingaben
2. **Negative Tests**: Fehlerhafte Eingaben
3. **Edge Cases**: Grenzwertige Szenarien
4. **Performance Tests**: Antwortzeiten und Token-Nutzung

## Iteration

Prompt-Engineering folgt einem iterativen Prozess:

1. Definition des Prompt-Musters
2. Test mit Beispieldaten
3. Bewertung der Ergebnisse
4. Anpassung basierend auf Feedback
5. Dokumentation der Änderungen
