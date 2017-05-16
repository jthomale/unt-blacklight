# frozen_string_literal: true
class CatalogController < ApplicationController

  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  def search_action_url options = {}
    options[:protocol] = request.headers['X-Forwarded-Proto'] or request.protocol
    super options
  end

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      qt: 'catalog-search',
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'catalog-search'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
    #  # q: '{!term f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title'
    config.index.display_type_field = 'material_type'

    # solr field configuration for document/show views
    config.show.title_field = 'main_title'
    config.show.display_type_field = 'material_type'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'material_type', label: 'Material Type'
    config.add_facet_field 'publication_dates', label: 'Publication Year'
    config.add_facet_field 'genre_terms_facet', label: 'Genre'
    config.add_facet_field 'topic_terms_facet', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'languages', label: 'Language', limit: true
    config.add_facet_field 'geographic_terms_facet', label: 'Region'
    config.add_facet_field 'era_terms_facet', label: 'Era'
    config.add_facet_field 'form_terms_facet', label: 'Form'
    config.add_facet_field 'people_facet', label: 'People', limit: 20
    config.add_facet_field 'corporations_facet', label: 'Corporations', limit: 20
    config.add_facet_field 'meetings_facet', label: 'Meetings', limit: 20

    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['material_type', 'languages']

    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #    :years_5 => { label: 'within 5 Years', fq: "publication_dates:[#{Time.zone.now.year - 5 } TO *]" },
    #    :years_10 => { label: 'within 10 Years', fq: "publication_dates:[#{Time.zone.now.year - 10 } TO *]" },
    #    :years_25 => { label: 'within 25 Years', fq: "publication_dates:[#{Time.zone.now.year - 25 } TO *]" }
    # }

    config.add_facet_field 'game_duration_facet_field', label: 'Games, Duration', :query => {
        :duration_1 => { label: 'less than 30 minutes', fq: "game_facet:d1t29" },
        :duration_30 => { label: '30 minutes to 1 hour', fq: "game_facet:d30t59" },
        :duration_60 => { label: '1 to 2 hours', fq: "game_facet:d60t120" },
        :duration_120 => { label: 'more than 2 hours', fq: "game_facet:d120t500" }
    }
    config.add_facet_field 'game_players_facet_field', label: 'Games, Number of Players', :query => {
        :players_1 => { label: '1 player', fq: "game_facet:p1" },
        :players_2 => { label: '2 to 4 players', fq: "game_facet:p2t4" },
        :players_4 => { label: '5 to 8 players', fq: "game_facet:p4t8" },
        :players_8 => { label: 'more than 8 players', fq: "game_facet:p9t99" }
    }
    config.add_facet_field 'game_age_facet_field', label: 'Games, Recommended Age', :query => {
        :age_1 => { label: '1 to 4 years', fq: "game_facet:a1t4" },
        :age_5 => { label: '5 to 9 years', fq: "game_facet:a5t9" },
        :age_10 => { label: '10 to 13 years', fq: "game_facet:a10t13" },
        :age_14 => { label: '14 to 16 years', fq: "game_facet:a14t16" },
        :age_17 => { label: '17 years and up', fq: "game_facet:a17t100" }
    }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'full_title', label: 'Title'
    config.add_index_field 'creator', label: 'Author/Creator'
    config.add_index_field 'contributors', label: 'Contributors'
    config.add_index_field 'material_type', label: 'Material Type'
    config.add_index_field 'languages', label: 'Languages'
    config.add_index_field 'publishers', label: 'Publisher'
    config.add_index_field 'publication_places', label: 'Publication Place'
    config.add_index_field 'publication_dates', label: 'Publication Date'
    config.add_index_field 'main_call_number', label: 'Call number'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'full_title', label: 'Title'
    config.add_show_field 'creator', label: 'Author/Creator'
    config.add_show_field 'contributors', label: 'Contributors'
    config.add_show_field 'material_type', label: 'Material Type'
    config.add_show_field 'urls', label: 'URLs'
    # config.add_show_field 'url_suppl_display', label: 'More Information'
    config.add_show_field 'languages', label: 'Languages'
    config.add_show_field 'publishers', label: 'Publisher'
    config.add_show_field 'publication_places', label: 'Publication Place'
    config.add_show_field 'publication_dates', label: 'Publication Date'
    config.add_show_field 'main_call_number', label: 'Call number'
    config.add_show_field 'isbn_numbers', label: 'ISBN'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'text', label: 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        qf: '$title_qf',
        pf: '$title_pf'
      }
    end

    config.add_search_field('Author/Creator') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'creator' }
      field.solr_local_parameters = {
        qf: '$creator_qf',
        pf: '$creator_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'catalog-search'
      field.solr_local_parameters = {
        qf: '$subject_qf',
        pf: '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', label: 'relevance'
    # config.add_sort_field 'publication_dates desc, title_sort asc', label: 'publication date'
    config.add_sort_field 'creator_sort asc, title_sort asc', label: 'creator'
    config.add_sort_field 'title_sort asc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end
end
