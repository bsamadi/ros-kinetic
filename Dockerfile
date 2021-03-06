FROM osrf/ros:kinetic-desktop
MAINTAINER Matt Droter matt@rosagriculture.org

# metadata
LABEL version="0.1"
LABEL description="ROS Agriculture tractor_sim."

ENV CATKIN_WS=/root/tractor_ws
RUN mkdir -p $CATKIN_WS/src
WORKDIR $CATKIN_WS/src

# download lawn_tractor_sim source 
RUN git clone -b 'v0.2-alpha' --single-branch --depth 1 https://github.com/ros-agriculture/ros_lawn_tractor.git 
RUN git clone https://github.com/bsb808/geonav_transform.git
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN echo "source $CATKIN_WS/devel/setup.bash" >> ~/.bashrc

# update apt-get because osrf image clears this cache and download deps
RUN apt-get -qq update && \
    apt-get -qq install -y \
        x11-apps \
	apt-utils \
	libeigen3-dev \
        python-catkin-tools  \
        less \
        ssh \
	vim \
	terminator \
        git-core \
        bash-completion \
        wget && \
    rosdep update && \
    rosdep install -y --from-paths . --ignore-src --rosdistro ${ROS_DISTRO} --as-root=apt:false && \
    apt-get -qq upgrade && \
    rm -rf /var/lib/apt/lists/*

# HACK, replacing shell with bash for later docker build commands
RUN mv /bin/sh /bin/sh-old && \
    ln -s /bin/bash /bin/sh

# build repo
WORKDIR $CATKIN_WS
ENV TERM xterm
ENV DISPLAY :0
ENV PYTHONIOENCODING UTF-8 

RUN source /ros_entrypoint.sh && \
catkin build --no-status
