#!/usr/bin/env python

__author__ = "Patrick K. O'Brien <pobrien@orbtech.com>"
__cvsid__ = "$Id$"
__revision__ = "$Revision$"[11:-2]

import sys
import zipfile
from cStringIO import StringIO

from docutils import core, io

import OOdirectives
import OOtext
import OOwriter


def main():
    pub = core.Publisher(writer=OOwriter.Writer())
    pub.set_reader('standalone', None, 'restructuredtext')
    settings = pub.get_settings()
    pub.source = io.FileInput(settings, source_path=sys.argv[1])
    pub.destination = io.StringOutput(settings)
    content = pub.publish()

    xml_manifest_list = [
        ('content.xml', content),
        ('styles.xml', OOtext.styles)
        ]

    xml_entries = []
    for docname, _ in xml_manifest_list:
        xml_entries.append(OOtext.m_xml_format % docname)

    image_manifest_list = OOtext.pictures

    image_entries = []
    for name in image_manifest_list:
        image_entries.append(OOtext.m_tif_format % name)

    manifest = OOtext.manifest % ('\n '.join(image_entries), '\n '.join(xml_entries))
    xml_manifest_list.append(('META-INF/manifest.xml', manifest))

    zip = zipfile.ZipFile(sys.argv[2], "w")
    for docname, contents in xml_manifest_list:
        zinfo = zipfile.ZipInfo(docname)
        zip.writestr(zinfo, contents)
    for name in image_manifest_list:
        zip.write(name, 'Pictures/' + name)
    zip.close()

if __name__ == '__main__':
    main()
