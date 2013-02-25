formatted_inventory do
    page_length 20

    page_heading <<TOP

            Node Report @<<<<<<<<<<<<<<<<<<<<<<<<<
                        time

Hostname:         Distribution:
-------------------------------------------------------------------------
TOP

    page_body <<BODY

@<<<<<<<<<<<<<<<< Operating System: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
identity,                           facts["operatingsystem"]
                           Release: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    facts["operatingsystemrelease"]
                      Architecture: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    facts["architecture"]
                        Processors: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                                    facts["processorcount"]

BODY
end
