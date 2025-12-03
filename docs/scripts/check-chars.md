# check-chars

Character counter utility for text, files, and stanzas.

## Synopsis

```bash
check-chars [OPTIONS]
```

## Description

Counts characters in text input, files, or paragraph-separated stanzas. Useful for checking character limits (e.g., Twitter, SMS).

## Options

- `-t, --text "text"` - Count characters in provided text
- `-f, --file <file>` - Count total characters in a file
- `-s, --stanzas <file>` - Count characters per stanza (blank-line separated)
- `-c, --chars <number>` - Set maximum character limit (default: 140)
- `-h, --help` - Show help message

## Examples

```bash
# Count characters in text
check-chars -t "Hello, world!"

# Count characters in a file
check-chars -f document.txt

# Count per stanza with custom limit
check-chars -s poem.txt -c 280

# Check Twitter-style limit
check-chars -t "Your tweet text here"
```

## Output Format

```
→ 45 chars, 95 left (limit: 140)
```

For stanzas, each stanza is displayed separately with its character count.

