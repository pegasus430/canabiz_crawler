#!/usr/bin/python
# -*- coding: UTF-8 -*-

from newsparser_hightimes import NPHighTimes
from newsparser_leafly import NPLeafly
from newsparser_marijuana import NPMarijuana
from newsparser_thecannabist import NPTheCannabist

import json

def parse_all_sites():
    parsers = []
    responses = []

    parsers.append(NPHighTimes())
    parsers.append(NPLeafly())
    parsers.append(NPMarijuana())
    parsers.append(NPTheCannabist())

    for parser in parsers:
        response = parser.parse()
        responses.append(response)

    return json.dumps(responses)

if __name__ == '__main__':
    print parse_all_sites()
