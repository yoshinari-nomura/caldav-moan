
require File.dirname(__FILE__) + '/webdav'

module Net
  class HTTP
    class Report < HTTPRequest
      METHOD = 'REPORT'
      REQUEST_HAS_BODY  = true
      RESPONSE_HAS_BODY = true
    end
  end
end

module Mhc
  class CalDav
    class Client < WebDav::Client

      def report(xml, path, depth = 1)
        print xml
        req = setup_request(Net::HTTP::Report, path)
        req['Depth'] = depth
        req.content_length = xml.size
        req.content_type = 'application/xml; charset="utf-8"'
        req.body = xml
        res = @http.request(req)
        #check_status_code(res, 207)
        return res
      end

      def report_calendar_multiget(href_list, path)
        xml = '<?xml version="1.0" encoding="utf-8" ?>'
        xml += <<-EOS
          <C:calendar-multiget xmlns:D="DAV:"
             xmlns:C="urn:ietf:params:xml:ns:caldav">
            <D:prop>
              <D:getetag/>
              <C:calendar-data/>
            </D:prop>
            #{href_list.map{|href| "<D:href>" + href + "</D:href>\n"}}
          </C:calendar-multiget>
        EOS
        db = SyncInfoDB.new
        res = report(xml, path)
        print res.body
        db.add_from_xml(res.body)
        return db
      end
    end # class Client

    class Cache < WebDav::Cache
      def report(xml, depth = 1)
        raise NotImplementedError
      end

      def report_calendar_multiget(path_list)
        raise NotImplementedError
      end
    end # class Cache
  end
end
