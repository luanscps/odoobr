FROM odoo:18.0

USER root

# Install system dependencies for Brazilian localization
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Development tools
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    \
    # Python development
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    \
    # Cryptography and SSL
    libssl-dev \
    libffi-dev \
    libcrypto++-dev \
    \
    # XML processing
    libxml2-dev \
    libxslt1-dev \
    \
    # Image processing
    libjpeg-dev \
    zlib1g-dev \
    \
    # Barcode and QR Code
    libzbar0 \
    \
    # PostgreSQL client
    postgresql-client \
    \
    # Utilities
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Install Python dependencies for Brazilian Localization and NFe
# Core dependencies
RUN pip install --no-cache-dir \
    # ERPBrasil - Brazilian utilities and validations
    'erpbrasil.base>=2.3.0' \
    'erpbrasil.assinatura>=1.2.0' \
    \
    # NFe transmission libraries
    'pytrustnfe3>=3.1.0' \
    'PyNFe>=5.0.0' \
    \
    # Financial processing
    'python3-cnab>=2.8.1' \
    'python3-boleto>=3.0.0' \
    'pycnab240>=2.8.2' \
    \
    # Text processing
    'num2words>=0.5.12' \
    'phonenumbers>=8.13.0' \
    'email-validator>=2.0.0' \
    \
    # XML handling
    'lxml>=4.9.0' \
    'xmltodict>=0.13.0' \
    \
    # Additional utilities
    'pycpf>=1.5.0' \
    'pycriteriaon>=0.2.0' \
    'python-dateutil>=2.8.2' \
    'requests>=2.28.0' \
    'zeep>=4.2.0' \
    \
    # Development and testing
    'pytest>=7.0.0' \
    'pytest-cov>=4.0.0'

# Clone and setup OCA l10n-brazil modules (optional, can be done via volume mount)
# Uncomment if you want modules pre-installed
# RUN mkdir -p /mnt/extra-addons && \
#     cd /mnt/extra-addons && \
#     git clone --branch 18.0 https://github.com/OCA/l10n-brazil.git

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

# Switch back to odoo user
USER odoo

# Create health check script
COPY --chown=odoo:odoo healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/healthcheck.sh 2>/dev/null || true

# Expose ports
EXPOSE 8069 8072

# Default command
CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
