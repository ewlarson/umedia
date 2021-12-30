require 'rsolr'
require 'json'

namespace :solr do
  desc "commit changes"
  task commit: [:environment] do
    SolrClient.new.commit
  end

  desc "optimize core"
  task optimize: [:environment] do
    SolrClient.new.optimize
  end

  desc "delete core index"
  task delete_index: [:environment] do
    SolrClient.new.delete_index
  end

  desc "backup solr data locally"
  task backup: [:environment] do
    SolrClient.new.backup(number_to_keep: 5)
  end

  desc "Restore latest backup"
  task restore: [:environment] do
    SolrClient.new.restore
  end

  desc "Restore latest backup"
  task restore: [:environment] do
    SolrClient.new.restore
  end

  desc "Public data.json file"
  task data_dump: [:environment] do
    # Afterward, to import json dump to Solr:
    # cat solr_docs.json |
    # jq -c '.[] |
    # {"index": {"_index": "core", "_type":"node", "_id": .uuid}}, .' |
    # curl -XPOST localhost:8983/_bulk --data-binary @-

    # Connect to solr
    solr = RSolr.connect url: ENV['SOLR_URL']

    # Search request
    response = solr.get 'select', params: { q: '*:*', rows: '100000' }

    docs = []
    response["response"]["docs"].each_with_index do |doc, _index|
      # Remove "score" from hash
      doc.delete("score")

      # Remove "version"
      doc.delete("_version_")

      # Remove schema.xml copyfields
      doc.delete("title_s")
      doc.delete("title_t")
      doc.delete("title_alternative_s")
      doc.delete("title_alternative_t")
      doc.delete("publisher_s")
      doc.delete("publisher_t")
      doc.delete("date_created_ss")
      doc.delete("creator_ss")
      doc.delete("contributor_ss")
      doc.delete("subject_ss")
      doc.delete("subject_fast_ss")
      doc.delete("collection_name_s")
      doc.delete("super_collection_name_ss")
      doc.delete("contributing_organization_name_s")

      # Add to docs array
      docs << doc
    end

    docs_file = Rails.root.join('public', 'solr_docs.json')
    File.open(docs_file, "w") { |f| f.write(JSON.generate(docs)) }
  end

  desc "Index public/data.json file"
  task index_data_dump: [:environment] do
    # Connect to solr
    solr = RSolr.connect url: ENV['SOLR_URL']

    # Parse solr_docs.json
    file = File.read(Rails.root.join('public', 'solr_docs.json'))
    data_hash = JSON.parse(file)

    # Add Doc to Solr
    data_hash.each do |doc|
      solr.add(doc)
    end

    # Commit
    solr.commit({softCommit: true})
  end
end
