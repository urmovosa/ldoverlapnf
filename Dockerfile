# Use nf-core base image
FROM nfcore/base:latest

LABEL authors="Anastasiia Alekseienko" \
      description="Docker image containing all requirements for LD overlap pipeline"

# Copy your environment.yml into the Docker image
COPY environment.yml /


# Use Conda to create the environment as per the environment.yml file
RUN conda env create -f environment.yml && conda clean -a
ENV PATH /opt/conda/envs/ldoverlapdeps/bin:$PATH

# Use the base image's entrypoint script to activate conda environment
ENTRYPOINT ["conda", "run", "-n", "ldoverlapdeps", "/bin/bash", "-c"]