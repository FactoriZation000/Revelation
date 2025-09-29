#version 450 core
#extension GL_KHR_shader_subgroup_arithmetic: require
#extension GL_KHR_shader_subgroup_ballot: require

const vec2 workGroupsRender = vec2(0.5f, 0.5f);

#include "/program/post/dof/DepthOfFieldTiling.comp"
