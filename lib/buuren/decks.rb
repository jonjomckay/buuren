require 'gst'
require 'mongoid'

require_relative 'models'

class Buuren::Decks
  def initialize(opts={})
    # TODO: Check for empty database
    host = opts[:host] || '127.0.0.1'
    port = opts[:port] || 27017
    database = opts[:database]

    # configure mongoid
    Mongoid.configure do |config|
      config.master = Mongo::Connection.new(host, port).db(database)
    end

    # create gstreamer playbin2 pipeline
    @pipeline = Gst::ElementFactory.make("playbin2")

    # create queries for track position and duration
    @position_query = Gst::QueryPosition.new(Gst::Format::TIME)
    @duration_query = Gst::QueryDuration.new(Gst::Format::TIME)

    # connect signal for when track is about to finish
    @pipeline.signal_connect("about-to-finish") do |element, data|
      # remove finishing track from now playing list and set the uri for the next track
      self.next_track(:about_to_finish => true)
    end
  end

  def set_uri(uri)
    # set pipeline state to null (initial) and set current track uri
    @pipeline.set_state(Gst::State::NULL)
    @pipeline.uri = uri
  end

  def initial?
    # check if pipeline state is null (initial)
    @pipeline.get_state[1].eql? Gst::STATE_NULL
  end

  def paused?
    # check if pipeline state is paused
    @pipeline.get_state[1].eql? Gst::STATE_PAUSED
  end

  def playing?
    # check if pipeline state is playing
    @pipeline.get_state[1].eql? Gst::STATE_PLAYING
  end

  def status
    # get pipeline state
    @pipeline.get_state[1]
  end

  def play
    begin
      # if pipeline state is null (initial) then play the next/first track in the now playing list
      if self.initial?
        self.queue_next_track
        @pipeline.play
        # else if pipeline is paused, then unpause
      elsif self.paused?
        @pipeline.play
      end
    rescue
      @pipeline.stop
    end
  end

  def queue_next_track
    begin
      filename = NowPlaying.first.track.filename

      @pipeline.uri = "file://#{filename}"
    end
  end

  def next_track(params={})
    # TODO: Split into 2 methods
    begin
      if NowPlaying.count > 0
        NowPlaying.first.remove_from_list
        NowPlaying.first.remove

        unless params[:about_to_finish]
          if self.playing?
            @pipeline.set_state(Gst::State::NULL)
          end
        end

        self.queue_next_track

        self.play
      end
    rescue
      @pipeline.stop
    end

  end

  def pause
    if self.playing?
      @pipeline.pause
    end
  end

  def stop
    @pipeline.stop
  end

  def duration
    begin
      # run query to get duration and convert to milliseconds
      @pipeline.query(@duration_query)
      duration = @duration_query.parse[1] / 1000000
    rescue
      duration = 0
    end

    duration
  end

  def volume
    @pipeline.volume
  end

  def volume=(volume_in_pc)
    # TODO: make into a real getter/setter?
    @pipeline.volume = volume_in_pc
  end

  def position
    begin
      # run query to get current position and convert to milliseconds
      @pipeline.query(@position_query)
      position = @position_query.parse[1] / 1000000
    rescue
      position = 0
    end

    position
  end

  def position=(position_in_ms)
    @pipeline.send_event(Gst::EventSeek.new(1.0, Gst::Format::Type::TIME, Gst::Seek::FLAG_FLUSH.to_i | Gst::Seek::FLAG_KEY_UNIT.to_i, Gst::Seek::TYPE_SET, position_in_ms * 1000000, Gst::Seek::TYPE_NONE, -1))
  end
end

#  #  # get the playbin bus
#  #  bus = @playbin.bus
#  #
#  #  # watch bus for messages
#  #  bus.add_watch do |bus, message|
#  #    handle_bus_message(message)
#  #  end
#  #end
#  #
#  #def status
#  #  # get playbin state
#  #  playbin_state = @playbin.state
#  #
#  #  case playbin_state[1]
#  #    when Gst::State::NULL
#  #      state = 'null'
#  #    when Gst::State::PAUSED
#  #      state = 'paused'
#  #    when Gst::State::PLAYING
#  #      state = 'playing'
#  #    when Gst::State::READY
#  #      state = 'ready'
#  #  end
#  #
#  #  # get current volume and uri
#  #  volume = @playbin.get_property("volume")
#  #  uri = @playbin.get_property("uri")
#  #  dp = self.duration_position()
#  #
#  #  # return merged hash
#  #  { 'state' => state, 'volume' => volume, 'uri' => uri }.merge(dp)
#  #end
#  #
#  #def handle_bus_message(message)
#  #  case message.type
#  #    when Gst::Message::Type::ERROR
#  #      # nullify the pipeline
#  #      @playbin.set_state(Gst::State::NULL)
#  #      # TODO: send a signal that playing is finished
#  #    when Gst::Message::Type::EOS
#  #      # nullify the pipeline
#  #      @playbin.set_state(Gst::State::NULL)
#  #      # TODO: send a signal that playing is finished
#  #    when Gst::Message::Type::TAG
#  #      tag_list = message.parse
#  #      tag_list.each do |key, val|
#  #        # TODO: store some of the data
#  #      end
#  #    when Gst::Message::Type::STATE_CHANGED
#  #      state = @playbin.get_state
#  #    else
#  #      # ??
#  #  end
#  #
#  #  true
#  #end
#end
