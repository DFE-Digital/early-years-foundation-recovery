class InteractiveComponentsController < ApplicationController
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
