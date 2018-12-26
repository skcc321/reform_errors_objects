require "test_helper"
require "reform/form/dry"

class ReformErrorsObjectsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ReformErrorsObjects::VERSION
  end

  Track  = Struct.new(:number)
  Album  = Struct.new(:title, :artist, :songs)
  Song   = Struct.new(:title, :tracks)
  Artist = Struct.new(:email, :label)
  Label  = Struct.new(:location)

  class AlbumForm < Reform::Form
    feature Reform::Form::Dry

    property :title

    validation do
      # required(:title).filled
      required(:title).filled
    end

    property :artist do
      property :email

      validation do
        required(:email).filled
      end

      property :label do
        property :location

        validation do
          required(:location).filled
        end
      end
    end

    # note the validation block is *in* the collection block, per item, so to speak.
    collection :songs do
      property :title

      validation do
        required(:title).filled
      end

      collection :tracks do
        property :number

        validation do
          required(:number).filled
        end
      end
    end
  end

  def setup
    @form = AlbumForm.new(Album.new(nil, Artist.new(nil, Label.new), [Song.new(nil, [Track.new(nil)]), Song.new(nil)]))
  end

  def test_that_it_collects_errors_hash
    @form.({ title: nil, artist: { email: "" }, songs: [{ title: "", tracks: [{ number: "" }] }, { title: "" }] })

    assert_equal @form.errors.objects, {
      title: ['must be filled'],
      artist: {
        email: ['must be filled'],
        label: {
          location: ["must be filled"]
        }
      },
      songs: {
        "0": {
          title: ['must be filled'],
          tracks: {
            "0": {
              number: ["must be filled"]
            }
          }
        },
        "1": {
          title: ["must be filled"]
        }
      }
    }
  end
end
