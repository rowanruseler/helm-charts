#!/usr/bin/env python3
"""Print a Markdown summary of a pgAdmin release notes page.

Usage: pgadmin-release-notes.py <release-notes-url>
Exits non-zero when the page has none of the expected sections.
"""

import sys
import urllib.request
from html.parser import HTMLParser

SECTIONS = {
    "new-features": "New features",
    "housekeeping": "Housekeeping",
    "bug-fixes": "Bug fixes",
}


class ReleaseNotesParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.entries = {key: [] for key in SECTIONS}
        self.section = None
        self.line = None
        self.link = None

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "section" and attrs.get("id") in SECTIONS:
            self.section = attrs["id"]
        elif tag == "section":
            self.section = None
        elif self.section and tag == "div" and attrs.get("class") == "line":
            self.line = []
            self.link = None
        elif self.line is not None and tag == "a" and self.link is None:
            self.link = attrs.get("href")
        elif self.line is not None and tag == "code":
            self.line.append("`")

    def handle_endtag(self, tag):
        if self.line is None:
            return
        if tag == "code":
            self.line.append("`")
        elif tag == "div":
            # Break @mentions so the PR body doesn't ping GitHub users.
            text = " ".join("".join(self.line).split()).replace("@", "@\u200b")
            if text:
                self.entries[self.section].append((text, self.link))
            self.line = None

    def handle_data(self, data):
        if self.line is not None:
            self.line.append(data)


def format_entry(text, link):
    # "Issue #9631 -  Collapse ..." -> "[#9631](link) Collapse ..."
    label, sep, description = text.partition(" - ")
    if sep and label.startswith("Issue #") and link:
        return f"- [{label.removeprefix('Issue ')}]({link}) {description.strip()}"
    return f"- {text}"


def main():
    url = sys.argv[1]
    with urllib.request.urlopen(url, timeout=30) as response:
        html = response.read().decode("utf-8")

    parser = ReleaseNotesParser()
    parser.feed(html)
    entries = parser.entries
    if not any(entries.values()):
        sys.exit(f"no release note entries found in {url}")

    counts = ", ".join(
        f"{title}: {len(entries[key])}" for key, title in SECTIONS.items() if entries[key]
    )
    print(f"pgAdmin [release notes]({url}). {counts}.")

    for key, title in SECTIONS.items():
        if not entries[key]:
            continue
        lines = "\n".join(format_entry(text, link) for text, link in entries[key])
        if key == "new-features":
            print(f"\n### {title}\n\n{lines}")
        else:
            print(f"\n<details>\n<summary>{title} ({len(entries[key])})</summary>\n\n{lines}\n\n</details>")


if __name__ == "__main__":
    main()
