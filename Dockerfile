FROM odoo:18.0

USER root

# Install system dependencies for Brazilian localization
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    # Python development
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    # Cryptography libraries
    libssl-dev \
    libffi-dev \
    # XML processing
    libxml2-dev \
    libxslt1-dev \
    # Image processing
    libjpeg-dev \
    zlib1g-dev \
    # Barcode support
    libzbar0 \
    # PostgreSQL client
    postgresql-client \
    # Utilities
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python requirements
# Using --ignore-installed to avoid Debian package conflicts
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install \
    --break-system-packages \
    --no-cache-dir \
    --ignore-installed \
    -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Verify critical packages (OCA requirements only)
RUN python3 <<PYEOF
import sys

packages = {
    'erpbrasil.base': 'ERPBrasil Base',
    'erpbrasil.assinatura': 'ERPBrasil Assinatura',
    'erpbrasil.edoc': 'ERPBrasil eDoc',
    'erpbrasil.transmissao': 'ERPBrasil Transmissão',
    'nfelib': 'NFe Library',
    'num2words': 'Num2Words',
    'brazilcep': 'Brazil CEP',
    'phonenumbers': 'Phone Numbers',
    'email_validator': 'Email Validator'
}

print('\n=== Verificando pacotes instalados ===')
failed = []
for pkg, name in packages.items():
    try:
        __import__(pkg.replace('-', '_'))
        print(f'✅ {name}')
    except ImportError as e:
        print(f'❌ {name}: {e}')
        failed.append(pkg)

if failed:
    print(f'\n❌ Pacotes faltando: {", ".join(failed)}')
    sys.exit(1)
else:
    print('\n✅ Todos os pacotes instalados com sucesso!')
PYEOF

# Create directories for data persistence
RUN mkdir -p \
    /var/lib/odoo/certificates \
    /var/lib/odoo/nfe_xml \
    /var/lib/odoo/nfse_xml \
    /var/log/odoo \
    /etc/odoo && \
    chown -R odoo:odoo \
    /var/lib/odoo \
    /var/log/odoo \
    /etc/odoo

# Switch to odoo user
USER odoo

# Copy health check script
COPY --chown=odoo:odoo healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/healthcheck.sh 2>/dev/null || true

# Expose ports
EXPOSE 8069 8072

# Default command
CMD ["odoo"]
