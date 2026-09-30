# LJT-Homepage

Personal academic homepage for **Junteng Liu**, forked from [AcademicPages](https://github.com/academicpages/academicpages.github.io).

## Content

- `_pages/about.md`: biography, research interests, academic background, research experience, all six publications, the recorded scholarship, and contact information.
- `_pages/publications.html`: the existing Publications page.
- `_data/publications.yml` and `_includes/publications-list.html`: one publication list shared by both pages.
- `_config.yml`: site identity, memory-provided profile links, project-site URL, and explicit exclusions for unrelated template content.

All personal and bibliographic information comes from the supplied memory. No specific technical-skills list or photograph was provided, so neither has been invented. Dates and ongoing roles are preserved as recorded; missing paper links and code-repository URLs have not been guessed. The repository owner is `riverhe459-lgtm`; the personal GitHub profile remains `Vicent0205`, as recorded in memory.

No new content pages are added. Template example pages and collections are excluded from the generated site, and no individual publication pages are generated.

## Build and publish

The existing workflow, **Build and deploy homepage**, builds Jekyll, verifies the two-page scope and publication/contact content, checks internal links, and uploads a Pages artifact. Deployment is conditional on Pages being enabled or explicitly requested.

To publish if Pages is not already enabled:

1. Enable GitHub Actions for the fork if GitHub requests it.
2. Open **Settings → Pages** and choose **GitHub Actions** as the source.
3. Run **Build and deploy homepage** on `master` with the **deploy** option enabled.

The configured site address is `https://riverhe459-lgtm.github.io/LJT-Homepage/`; configuration alone does not mean that deployment has completed.

For a local check:

```sh
bundle install
bundle exec jekyll build --strict_front_matter
bundle exec ruby scripts/verify_site.rb
```

The original theme license and attribution are retained.
