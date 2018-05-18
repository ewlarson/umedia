class UmediaETL
  attr_reader :oai_endpoint,
              :set_spec_pattern,
              :field_mappings,
              :filter_callback,
              :set_spec_filter,
              :solr_connection
  def initialize(oai_endpoint: 'http://cdm16022.contentdm.oclc.org/oai/oai.php',
                 set_spec_pattern: /'^ul_([a-zA-Z0-9])*\s-\s'/,
                 field_mappings: Umedia::Transformer.field_mappings,
                 filter_callback: CDMBL::RegexFilterCallback,
                 set_spec_filter: CDMBL::FilteredSetSpecs,
                 solr_connection: SolrConnection.new)
    @oai_endpoint     = oai_endpoint
    @set_spec_pattern = set_spec_pattern
    @field_mappings   = field_mappings
    @filter_callback  = filter_callback
    @set_spec_filter  = set_spec_filter
    @solr_connection  = solr_connection
  end

  def config
    {
      oai_endpoint: oai_endpoint,
      extract_compounds: true,
      field_mappings: field_mappings,
      cdm_endpoint: 'https://server16022.contentdm.oclc.org/dmwebservices/index.php',
      max_compounds: 1,
      batch_size: 5,
      solr_config: solr_config
    }
  end

  def set_specs
    @set_specs ||= filtered_set_specs
  end

  private

  def umedia_filter
    filter_callback.new(field: 'setName',
                        pattern: set_spec_pattern,
                        inclusive: false)
  end

  def filtered_set_specs
    set_spec_filter.new(oai_base_url: oai_endpoint,
                        callback: umedia_filter).set_specs
  end

  def solr_config
    { url: solr_connection.url }
  end
end
