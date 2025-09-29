#version 450 core
#extension GL_KHR_shader_subgroup_arithmetic: require

const vec2 workGroupsRender = vec2(0.5f, 0.5f);

#include "/program/post/dof/DepthOfFieldGenerateCOC.comp"
