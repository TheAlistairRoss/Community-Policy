package k8sazureforbiddensysctls

violation[{"msg": msg, "details": {}}] {
    sysctl := input.review.object.spec.securityContext.sysctls[_].name
    forbidden_sysctl(sysctl)
    msg := sprintf("The sysctl %v is not allowed, pod: %v. Forbidden sysctls: %v", [sysctl, input.review.object.metadata.name, input.parameters.forbiddenSysctls])
}

# * may be used to forbid all sysctls
forbidden_sysctl(sysctl) {
    input.parameters.forbiddenSysctls[_] == "*"
}

forbidden_sysctl(sysctl) {
    input.parameters.forbiddenSysctls[_] == sysctl
}

forbidden_sysctl(sysctl) {
    # Escape any existing periods so they are matched exactly
    initial := replace(input.parameters.forbiddenSysctls[_], ".", `\.`)
    # Replace any wildcard * characters with the .+ regex wildcard
    pattern := replace(initial, "*", `.+`)
    re_match(sprintf("^%v$", [pattern]), sysctl)
}
