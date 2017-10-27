# Yoast ACF Analysis VVV development site setup

This repo is to be used to set up a development site with [Varying Vagrant Vagrants (VVV)](https://github.com/Varying-Vagrant-Vagrants/VVV) for working on https://github.com/Yoast/yoast-acf-analysis.

## Installation

All you need to do is add this section to the `site` section of your `vvv-config.yml`

    yoast-acf-analysis-development:
        repo: https://github.com/kraftner/yoast-acf-analysis-development.git
        hosts:
            - yoast-acf-analysis.vvv.dev

If you do not want to provision the default sites that come with VVV make sure to *only* have this in the `site` section.

For more details on configuring VVV please consult the [VVV documentation](https://varyingvagrantvagrants.org/docs/en-US/vvv-config/).

## Tests

### PHPUnit

The PHPUnit Tests can be run from the plugin folder with the script `composer run test`.

### Nightwatch JS Tests

To be able to run the [Nightwatch](http://nightwatchjs.org/) browser tests you also need to have Chrome and xfvb installed:

If you want to auto-configure your VVV machine with those add the following to your `vvv-config.yml`

    utilities:
      yoast-acf-analysis-development-utilities:
        - chrome
        - xvfb
    utility-sources:
      yoast-acf-analysis-development-utilities: https://github.com/kraftner/yoast-acf-analysis-development-utilities.git

After that to run the tests for ACF 4 run `npm run test-acf4` inside the plugin folder.

To run the tests for ACF 5 you first need to install ACF 5 as we cannot do this automatically as it isn't a free plugin.
After you've done that you can simply run `npm run test-acf5pro`.

If you do not want to run the browser tests with chrome, headless, inside your VVV machine you'll need to change some of `nightwatch.json`, `nightwatch.conf.example.js` and `env.js`. Consult the corresponding documentation on how to do that.
