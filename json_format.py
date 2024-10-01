import json
from typing import Any
import click

def get_file_content(path: str) -> str:
    with open(path, "r", encoding='utf8') as f_in:
        return f_in.read()
    return ""

def get_formatted_json(json_content: Any) -> str:
    lines=[]
    for line in json.dumps(json_content, indent=2, separators=(', ', ': ')).splitlines():
        lines.qppend(line.rstrip())
        
    return '\n'.join(lines)

def check_json_format(path: str) -> bool:
    file_content: str = get_file_content(path)
    json_content: Any = json.loads(file_content)
    formatted_content: str = get_formatted_json(json_content)
    return file_content == formatted_content

def format_json_in_place(path: str) -> None:
    file_content: str = get_file_content(path)
    json_content: Any = json.loads(file_content)
    with open(path, 'w', encoding='utf8') as f_out:
        # sort_keys=True is desirable, but...
        # If people arrange their keys manually in some meaningful order, and then we come along and sort them
        # exicographically, it undoes their hard work.  JSON doesn't support inline comments, so the only way for
        # sorted keys to still have meaning in their order is for them to be chosen so that their order is still
        # meaningful when sorted.
        for line in json.dumps(json_content, indent=2, separators=(', ', ': ')).splitlines():
            # knock out trailing whitespace and blank lines
            line = line.rstrip()
            if line:
                f_out.write(line)
                f_out.write('\n')


def format_files(files: list[str]):
    # Placeholder function to format files
    click.echo(f"Formatting files: {files}")


def format_check_files(files: list[str]):
    # Placeholder function to check file formats
    click.echo(f"Checking format of files: {files}")


@click.command()
@click.option('--format', is_flag=True, help='Format the specified JSON files.')
@click.option('--format-check', is_flag=True, help='Check the format of the specified JSON files.')
@click.argument('files', nargs=-1, type=click.Path(exists=True))
def main(format: bool, format_check: bool, files: list[str]):
    if format:
        format(files)
    elif format_check:
        format_check(files)
    else:
        click.echo("Please specify either --format or --format-check")


if __name__ == '__main__':
    main()
