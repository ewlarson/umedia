require 'sidekiq'

require 'sidekiq/testing'
Sidekiq::Testing.inline!

# Delete a batch of thumbnails
class TranscriptsIndexerWorker
  include Sidekiq::Worker

  attr_writer :indexer_klass
  attr_reader :page, :set_spec
  def perform(page = 1, set_spec = false)
    @page = page
    @set_spec = set_spec
    indexer.index!
    unless indexer.empty?
      TranscriptsIndexerWorker.perform_async(indexer.next_page, set_spec)
    end
  end

  def indexer_klass
    @indexer_klass ||= Umedia::IndexTranscripts
  end

  def indexer
    @indexer ||= indexer_klass.new(set_spec: set_spec, page: page)
  end
end
