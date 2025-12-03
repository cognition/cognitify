# mkfolders

Creates directories from a list in a file.

## Synopsis

```bash
mkfolders <filename>
```

## Description

Reads a file line by line and creates a directory for each line in the current working directory.

## Parameters

- `<filename>` - File containing directory names (one per line)

## Example

```bash
# Create directories from list.txt
echo -e "project1\nproject2\nproject3" > list.txt
mkfolders list.txt
# Creates: ./project1, ./project2, ./project3
```

## Use Cases

- Bulk directory creation
- Project scaffolding
- Organizing files into directories

## Notes

- Directories are created in the current working directory
- Existing directories are skipped
- Empty lines are ignored
- Errors are reported but don't stop processing

