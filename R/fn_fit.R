fitContingencyIPF <- function(
    seed,
    targets,
    target_names
) {
  
  mipfp::Ipfp(
    seed = seed,
    target.list = target_names,
    target.data = targets
  )
}