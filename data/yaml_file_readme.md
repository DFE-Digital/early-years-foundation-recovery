# YAML file README

The content and flow of most pages in this app are defined via a set of YAML files.
There are four types of file:

1. [Overview of training modules](#overview-of-training-modules)
2. [Training module structure](#training-module-structure)
3. [Training module content](#training-module-content)
4. [Questionnaires](#questionnaires)

## Overview of Training Modules

`/data/training-module.yml`

Training modules defined in this file appear in the list of modules on the `training_modules#index` page `/modules`.
The data are store in `TrainingModule` instances.

### Data Structure

```yaml
training_module_name:
  title: The module name as it will appear on the page
  thumbnail: Image file name as seen in a card within the my learning page
  description: The module description
  depends_on: The name of a dependent module that must be completed before this module can be started
```

The training module name can be any string.
It identifies the training module throughout the app and appears in URLs specific to that module.

## Training module structure

`/data/modules/<training_module_name>.yml`

This file defines the structure of the training module.
Pages will appear in the order they are defined in this file.
This file also defines each page type:
- `text_page`
- `youtube_page`
- `formative_assessment`

### Data Structure

```yaml
training_module_name:
  page_name:
    type: text_page
```

Each page will be displayed at:

`/modules/<training_module_name>/content_pages/<page_name>`

Page names are typically a numerical hierarchical sequence that proceeds as `1`,`1-1`,`1-1-1`,`1-1-2`...
although any text will work.
That structure was chosen to identify topic groups (third digit in sequence).
So if you deviate from the structure topic grouping will not work for that training module.

There are two page types:

* **Content pages** - this type defines which of the page templates are used to display the page.
  The `type` will match the template name `app/views/content_pages/<type>.html.slim`
* **Questionnaires** - these are groups of questions and answers.
  The `type` defines how the questionnaire will be handled.
  In `app/controllers/application_controller.rb` the method `questionnaire_path` uses the `type` to direct the user to a matching controller.

A page type is also used to define an object that provides methods that match the requirement for that type of page.
The mapping is defined in `ModuleItem::MODELS`.

## Training module content

`/config/locales/modules/<training_module_name>.yml`

These files are Rails translation files.
They are designed to be accessed via the matching page object.
They define the content that will be inserted into the matching page template.

### Data Structure

Note that all these pages start with a language abbreviation, for example `en`, and the key `modules` like this:

```yaml
en:
  modules:
```

The files can be split and moved into sub-folders if that makes them easier to manage.

#### ContentPage

```yaml
en:
  modules:
    training_module_name:
      page_name:
        heading: |
          The text that will appear at the top of the page
        body: |
          Govspeak flavoured markdown
        image: optional_path_to_image_file.jpg
```

**Note**
The image needs to exist in `app/assets/images` and its full name with extension are needed.
The image will be positioned below the heading and the markdown content beneath that.


#### YoutubePage

```yaml
en:
  modules:
    training_module_name:
      page_name:
        heading: The text that will appear at the top of the page
        video_title: The title used for the video
        youtube_url: The URL for an embed YouTube item
        body: Govspeak markdown that will be placed below the elements above
```

To get the embed YouTube URL, find the video on YouTube and select *Share*.
Then click on the *Embed* option.
The URL will be presented as the `src` attribute in the code snippet that appears.

The video will appear between the heading and the body

#### Questionnaire

At the moment questionnaire content defined in the translation files does not appear on the page.
Instead the page content is defined within the questionnaire data (see below):

## Questionnaires

`/data/questionnaires/<training_module_name>.yml`

These files define the behaviour of questionnaires.
There are three main behaviours required:

1. Formative Assessment
2. Summative Assessment
3. Confidence Check

At time of writing only Formative Assessment has been defined in code.

There is a generic Questionnaire model/structure that will probably become redundant when all three main types of questionnaire behaviour have been defined.

### Data structure

```yaml
training_module_name:
  page_name:
    heading: Content for the top of the page
    content: Content for the body of the page
    required_percentage_correct: Optional - assumed 100% if not set
    questions:
      question_name:
        multi_select: defines whether to use checkboxes(true) or radios(false)
        label: Content label for form input for this question
        assessment_summary: Output for result banner for this question
        assessment_fail_summary: Optional - alternative result text on fail
        answers:
          answer_name: Answer label that will appear on page
        correct_answers:
          - Array of answer names to match against to determine success
```

The structure uses question and answer names to identify individual elements.
Using humanized names will make the code more readable, but is not essential.
If you run out of names `a` `b` `c` will work fine.
However, question names must be unique within each questionnaire, and answer names within each question.

Also be aware that `true` `false` `yes` and `no` are translated into booleans by YAML so put them in quotes when using them for answers.

If both `required_percentage_correct` and `correct_answers` are absent the percentage correct level is assumed to be 0% - that is, a submission will always be valid.
