# Yoast ACF Analysis VVV development site setup

This repo is to be used to set up a development site with [Varying Vagrant Vagrants (VVV)](https://github.com/Varying-Vagrant-Vagrants/VVV) for working on https://github.com/Yoast/yoast-acf-analysis.

## Installation

All you need to do is add this section to the `sites` section of your `vvv-custom.yml`

    yoast-acf-analysis-development:
        repo: https://github.com/kraftner/yoast-acf-analysis-development.git
        hosts:
            - yoast-acf.dev

**Note that you can change `yoast-acf.dev` to any other name, if that's what you prefer.**

If you do not want to provision the default sites that come with VVV make sure to *only* have this in the `site` section.

For more details on configuring VVV please consult the [VVV documentation](https://varyingvagrantvagrants.org/docs/en-US/vvv-config/).

Reprovision your VVV by running `vagrant provision`. After this, ensure you run `composer install` and `yarn install` (or `npm install`) in the plugin folder before proceeding.

## Tests

### PHPUnit

The PHPUnit Tests can be run from the plugin folder with the script `composer run test`.

### Nightwatch JS Tests

To be able to run the [Nightwatch](http://nightwatchjs.org/) browser tests you also need to have Chrome and xfvb installed:

If you want to auto-configure your VVV machine with those add the following to your `vvv-custom.yml`

    utilities:
      yoast-acf-analysis-development-utilities:
        - chrome
        - xvfb
    utility-sources:
      yoast-acf-analysis-development-utilities: https://github.com/kraftner/yoast-acf-analysis-development-utilities.git

After that to run the tests for ACF 4 run `npm run test-acf4` inside the plugin folder.

To run tests for ACF 5 you first need to install ACF 5 manually, as we cannot do this automatically due to it not being a free plugin.
After you've installed ACF 5, you can simply run `npm run test-acf5pro`.

**Note:**
If you do not want to run the browser tests with Chrome and/or in headless mode, you'll need to change `nightwatch.json`, `nightwatch.conf.example.js` and `env.js` in your virtual machine. 

Consult the corresponding documentation on how to do that.
