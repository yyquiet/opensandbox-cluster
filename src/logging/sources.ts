/** Daily log file prefixes and their minimum severity. */
export const LOG_SOURCE_PREFIXES = [
  { prefix: "opensandbox-cluster", minLevel: null },
  { prefix: "opensandbox-cluster.err", minLevel: "error" },
] as const;

/** Resolve the configured log directory relative to the process working directory. */
export function readLogDir(): string {
  return process.env.LOG_DIR ?? "./data/logs";
}
