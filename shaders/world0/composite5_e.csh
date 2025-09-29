#version 450 core

const vec2 workGroupsRender = vec2(1.0f, 1.0f);

#include "/program/post/dof/DepthOfFieldMedianFilter.comp"
