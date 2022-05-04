import "@hotwired/turbo-rails";
// import "./controllers";

import { initAll } from "govuk-frontend";

/*
WIP: asset pipeline needs the following from the gem
https://github.com/alphagov/govuk_publishing_components/blob/main/docs/install-and-use.md
*/
import "govuk_publishing_components/dependencies";
import "govuk_publishing_components/lib";
import "govuk_publishing_components/components/button";


initAll();
