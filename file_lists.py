import os
import re
from typing import Dict, Iterable, List, Pattern, Set

from git import Repo


def classify_files_by_regex(filenames: Iterable[str], regex_dict: Dict[str, Pattern]) -> Dict[str, Set[str]]:
    """
    Classifies filenames into categories based on matching regular expressions.

    :param filenames: A list of filenames to classify.
    :param regex_dict: A dictionary where keys are category names and values are lists of regular expressions.
    :return: A dictionary where keys are category names and values are sets of filenames that match the category.
    """
    # Prepare the result dictionary with empty sets for each category
    classified_files = {category: set() for category in regex_dict}

    # Classify each file
    for filename in filenames:
        for category, pattern in regex_dict.items():
            # Check if the filename matches any pattern in the current category
            if pattern.search(filename):
                classified_files[category].add(filename)

    return classified_files


def get_files_in_path(path: str) -> Set[str]:
    """
    Returns a set of file paths. If the input path is a directory, returns all files in that directory.
    If the input path is a file, returns a set containing only that file.

    :param path: The directory or file path.
    :return: A set of file paths.
    """
    files: Set[str] = set()

    if os.path.isdir(path):
        # Walk through the directory and add all files to the set
        for root, _, filenames in os.walk(path):
            for filename in filenames:
                files.add(os.path.join(root, filename))
    elif os.path.isfile(path):
        # If it's a file, add the path itself
        files.add(path)
    # else ignore whatever it is

    return files


def get_git_changed_files(repo_path: str) -> Set[str]:
    """
    Returns a set of files that are either unstaged or staged in the git repository.
    Specifically, files that are added, modified, or untracked, but which are not ruled
    out by .gitignore file.

    :param repo_path: The root directory of the git repository.
    :return: A set of file paths that are either unstaged or staged.
    """
    # Initialize the repo
    repo = Repo(repo_path)

    # Ensure the repo is valid
    if repo.bare:
        return set()

    # Get the list of unstaged files (modified and untracked files)
    unstaged_files: Set[str] = {item.a_path for item in repo.index.diff(
        None) if os.path.isfile(os.path.join(repo_path, item.a_path))}

    # Get the list of staged files
    staged_files: Set[str] = {item.a_path for item in repo.index.diff('HEAD')}

    # Combine both sets
    all_changed_files: Set[str] = unstaged_files | staged_files

    return all_changed_files


def merge_regex_patterns(regex_list: List[str]) -> Pattern:
    """
    Merges a list of regular expressions into a single compiled regular expression
    that matches the union of all the individual expressions.

    :param regex_list: A list of regular expression strings.
    :return: A compiled regular expression pattern.
    """
    # Join the regular expressions with the alternation operator '|'
    merged_pattern = '|'.join(f"(?:{regex})" for regex in regex_list)

    # Compile the merged regular expression
    return re.compile(merged_pattern)
