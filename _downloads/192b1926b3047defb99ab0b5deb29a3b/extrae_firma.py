#!/usr/bin/env python3

import sys
from asn1crypto import cms

if len(sys.argv) < 2:
    print("Falta el archivo de firma .p7s", file=sys.stderr)
    sys.exit(1)

filename: str = sys.argv[1]

# OID del sello de tiempo
TSA_OID = "1.2.840.113549.1.9.16.2.14"

# Cargamos el contenido del archivo.
with open(filename, 'rb') as f:
    content_info = cms.ContentInfo.load(f.read())

signer_infos = content_info['content']['signer_infos']

# Para cada firmante extraemos la firma
for i, signer_info in enumerate(signer_infos):
    signature_bytes = signer_info['signature'].native
    output = f"{filename}-signature{i}"

    with open(output, "wb") as f_out:
        f_out.write(signature_bytes)
        print(f"Firma nº{i+1} extraída: {len(signature_bytes)} bytes.")

    timestamp_token = None

    unsigned_attrs = signer_info['unsigned_attrs']

    if unsigned_attrs is None:
        print(f"La firma nº{i+1} no tiene sello")
        continue

    output = f"{filename}-timestamp{i}"

    for attr in unsigned_attrs:
        if attr['type'].dotted == TSA_OID:
            timestamp_bytes = attr['values'][0].dump()

            with open(output, "wb") as f_out:
                f_out.write(timestamp_bytes)
                print(f"Sello de tiempo nº{i+1} extraído: {len(timestamp_bytes)} bytes.")

            break

print(f"\n{len(signer_infos)} firmas extraídas en total.")

