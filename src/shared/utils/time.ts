/**
 * 将秒数格式化为 "Xh Ym" 形式
 * - 不足 1 分钟显示 "0m"
 * - 只有分钟时省略小时
 */
export function formatDuration(seconds: number): string {
  if (seconds <= 0) return '0m';

  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);

  if (h > 0 && m > 0) return `${h}h ${m}m`;
  if (h > 0) return `${h}h`;
  return `${m}m`;
}
