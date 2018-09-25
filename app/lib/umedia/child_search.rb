# frozen_string_literal: true

module Umedia
  # Search for Child records
  class ChildSearch
    attr_reader :q, :page, :rows, :fl, :parent_id, :client, :item_list_klass
    def initialize(q: '',
                   page: 1,
                   rows: 3,
                   fl: 'title, id, object, parent_id, child_viewer_types, viewer_type',
                   parent_id: '',
                   client: SolrClient,
                   item_list_klass: Parhelion::ItemList)
      @q = q
      @page = page
      @rows = rows
      @fl = fl
      @parent_id = parent_id
      @client = client
      @item_list_klass = item_list_klass
    end

    def empty?
      response['response']['docs'].length == 0
    end

    def num_found
      response['response']['numFound']
    end

    def items
      item_list_klass.new(results: response['response']['docs'])
    end

    def highlighting
      response['highlighting']
    end

    def response
      @response ||= client.new.solr.paginate page, rows, 'child_search', params: {
        q: q,
        'q.alt': '*:*',
        sort: 'child_index asc',
        hl: 'on',
        fl: fl,
        'hl.method': 'unified',
        fq: ["parent_id:\"#{parent_id}\""]
      }
    end
  end
end
