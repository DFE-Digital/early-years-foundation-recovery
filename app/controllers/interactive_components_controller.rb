class InteractiveComponentsController < ApplicationController
  def index
    @hotspot_example = {
      id: 'learning-room',
      image: 'interactive-components/learning-room.jpg',
      alt: 'An early-years room with a reading corner, a play area and low storage shelves.',
      hotspots: [
        {
          id: 'reading-corner',
          label: 'Reading corner',
          x: 20,
          y: 35,
          description: 'A comfortable reading space gives children opportunities to explore books and share stories.',
        },
        {
          id: 'play-area',
          label: 'Play area',
          x: 50,
          y: 65,
          description: 'An open play area gives children space to explore materials and play together.',
        },
        {
          id: 'storage',
          label: 'Accessible storage',
          x: 85,
          y: 45,
          description: 'Clearly organised resources within reach can help children choose activities independently.',
        },
      ],
    }
  end
end
