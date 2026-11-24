class InteractiveComponentsController < ApplicationController
  def example_1
    @training_module = Training::Module.by_name('brain-development-and-how-children-learn')
    @content = @training_module&.page_by_name('2-1-2-1a')

    return render('errors/not_found', status: :not_found) if @content.blank?

    body = @content.body.to_s
    insertion_point = 'Piaget also believed that children:'
    @body_before_flip_cards = body
    @body_after_flip_cards = ''

    if body.scan(insertion_point).one?
      @body_before_flip_cards, introduction, remaining_body = body.partition(insertion_point)
      @body_after_flip_cards = introduction + remaining_body
    end
  end

  def example_2
    @training_module = Training::Module.by_name('brain-development-and-how-children-learn')
    @content = @training_module&.page_by_name('2-1-3-4a')

    return render('errors/not_found', status: :not_found) if @content.blank?

    body = @content.body.to_s
    insertion_point = 'child can continue to progress.'
    @body_before_flip_cards = body
    @body_after_flip_cards = ''

    if body.scan(insertion_point).one?
      preceding_body, sentence_ending, @body_after_flip_cards = body.partition(insertion_point)
      @body_before_flip_cards = preceding_body + sentence_ending
    end
  end

  def example_3
    @training_module = Training::Module.by_name('module-8')
    @content = @training_module&.page_by_name('8-1-2-3')

    return render('errors/not_found', status: :not_found) if @content.blank?

    body = @content.body.to_s
    @body_before_hotspot = body
    @body_after_hotspot = ''
    heading_position = body.index('Curriculum progression model')
    return unless heading_position

    image = body.match(/!\[([^\]]*)\]\(([^\s)]+)\)/, heading_position)
    return unless image

    @body_before_hotspot = body[0...image.begin(0)]
    @body_after_hotspot = body[image.end(0)..]
    @hotspot_example = {
      id: 'curriculum-progression-model',
      image: image[2].start_with?('//') ? "https:#{image[2]}" : image[2],
      alt: image[1].presence || 'Curriculum progression model',
      hotspots: [
        {
          id: 'step-1',
          label: 'Curriculum',
          x: 17.5,
          y: 25,
          desktop_placement: 'bottom-start',
          description: 'Plan the curriculum and what you want children to learn.',
        },
        {
          id: 'step-2',
          label: 'Pedagogy',
          x: 50,
          y: 25,
          desktop_placement: 'bottom',
          description: 'Identify and deliver your chosen teaching and learning approaches.',
        },
        {
          id: 'step-3',
          label: 'Assessment',
          x: 82.5,
          y: 25,
          desktop_placement: 'top-start',
          description: 'Observe and assess whether your approaches are having the impact you wanted.',
        },
        {
          id: 'step-4',
          label: 'Adapt your approaches',
          x: 68,
          y: 85,
          desktop_placement: 'top',
          description: 'Where needed, adapt your approaches to ensure all children secure the intended learning.',
        },
      ],
    }
  end

  def index
    @hotspot_example = {
      id: 'learning-room',
      image: 'interactive-components/learning-room.jpg',
      alt: 'Image of a play room set up. In the centre of the room there is an activities table, on the right role play equipment and on the left a reading corner. Tab to find out more about these areas.',
      hotspots: [
        {
          id: 'reading-corner',
          label: 'Reading corner',
          x: 20,
          y: 35,
          desktop_placement: 'bottom-start',
          description: 'A comfortable reading space gives children opportunities to explore books and share stories.',
        },
        {
          id: 'play-area',
          label: 'Play area',
          x: 50,
          y: 65,
          desktop_placement: 'top',
          description: 'An open play area gives children space to explore materials and play together.',
        },
        {
          id: 'storage',
          label: 'Accessible storage',
          x: 85,
          y: 45,
          desktop_placement: 'top-end',
          description: 'Clearly organised resources within reach can help children choose activities independently.',
        },
      ],
    }
  end
end
