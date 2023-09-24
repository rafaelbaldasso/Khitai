from usp.tree import sitemap_tree_for_homepage
import sys

# https://pypi.org/project/ultimate-sitemap-parser/

tree = sitemap_tree_for_homepage(sys.argv[1])
for page in tree.all_pages():
    print(page)
