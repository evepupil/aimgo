import { FlatList } from 'react-native';
import { XStack, YStack, Text } from 'tamagui';
import { useColorScheme } from 'react-native';
import { useTranslation } from 'react-i18next';
import { Target, Flag, CheckSquare, Search } from 'lucide-react-native';
import { colors, radius, spacing } from '@/src/constants/theme';
import { EmptyState } from '@/src/shared/components/ui';
import type { SearchResultItem } from '../hooks/useSearch';

type SearchResultsProps = {
  results: SearchResultItem[];
  keyword: string;
  isSearching: boolean;
  onGoalPress: (goalId: string) => void;
  onMilestonePress: (milestoneId: string) => void;
  onTaskPress: (taskId: string) => void;
};

// 类型标签配置：labelKey 对应 goals 命名空间的 key
const TYPE_CONFIG = {
  goal: { labelKey: 'title' as const, Icon: Target },
  milestone: { labelKey: 'milestone' as const, Icon: Flag },
  task: { labelKey: 'task' as const, Icon: CheckSquare },
};

// 转义正则特殊字符
function escapeRegex(str: string): string {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// 高亮匹配文本
function HighlightText({
  text: content,
  keyword,
  accentColor,
  textColor,
}: {
  text: string;
  keyword: string;
  accentColor: string;
  textColor: string;
}) {
  if (!keyword.trim()) {
    return (
      <Text fontSize="$3" color={textColor} numberOfLines={1}>
        {content}
      </Text>
    );
  }

  const parts = content.split(new RegExp(`(${escapeRegex(keyword)})`, 'gi'));

  return (
    <Text fontSize="$3" color={textColor} numberOfLines={1}>
      {parts.map((part, i) =>
        part.toLowerCase() === keyword.toLowerCase() ? (
          <Text key={i} color={accentColor} fontWeight="700">
            {part}
          </Text>
        ) : (
          part
        ),
      )}
    </Text>
  );
}

// 搜索结果列表组件
export function SearchResults({
  results,
  keyword,
  isSearching,
  onGoalPress,
  onMilestonePress,
  onTaskPress,
}: SearchResultsProps) {
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;
  const { t } = useTranslation('goals');

  // 搜索中状态
  if (isSearching) {
    return (
      <YStack flex={1} alignItems="center" justifyContent="center" padding="$6">
        <Text color={theme.textMuted} fontSize="$3">
          {t('searching', { defaultValue: '搜索中...' })}
        </Text>
      </YStack>
    );
  }

  // 有关键词但无结果
  if (keyword.trim() && results.length === 0) {
    return (
      <EmptyState
        icon={<Search size={32} color={theme.textMuted} />}
        message={t('noSearchResults', {
          defaultValue: '未找到匹配结果',
        })}
      />
    );
  }

  // 未输入关键词
  if (!keyword.trim()) {
    return null;
  }

  const handlePress = (item: SearchResultItem) => {
    switch (item.type) {
      case 'goal':
        onGoalPress(item.id);
        break;
      case 'milestone':
        onMilestonePress(item.id);
        break;
      case 'task':
        onTaskPress(item.id);
        break;
    }
  };

  const renderItem = ({ item }: { item: SearchResultItem }) => {
    const config = TYPE_CONFIG[item.type];
    const iconColor = item.goalColor ?? theme.accent;
    const Icon = config.Icon;

    return (
      <XStack
        paddingVertical={spacing.sm}
        paddingHorizontal={spacing.md}
        gap={spacing.sm}
        alignItems="center"
        pressStyle={{ opacity: 0.7 }}
        onPress={() => handlePress(item)}
      >
        {/* 类型图标 */}
        <YStack
          width={36}
          height={36}
          borderRadius={radius.sm}
          backgroundColor={`${iconColor}20`}
          alignItems="center"
          justifyContent="center"
        >
          <Icon size={18} color={iconColor} />
        </YStack>

        {/* 标题与上下文 */}
        <YStack flex={1} gap={2}>
          <HighlightText
            text={item.title}
            keyword={keyword}
            accentColor={theme.accent}
            textColor={
              item.isCompleted ? theme.textMuted : theme.text
            }
          />

          {/* 父级上下文信息 */}
          {item.parentTitle ? (
            <Text fontSize="$2" color={theme.textSecondary} numberOfLines={1}>
              {t(config.labelKey)} · {item.parentTitle}
            </Text>
          ) : (
            <Text fontSize="$2" color={theme.textSecondary}>
              {t(config.labelKey)}
            </Text>
          )}
        </YStack>

        {/* 已完成标记 */}
        {item.isCompleted && (
          <Text fontSize="$2" color={theme.success}>
            {t('completed')}
          </Text>
        )}
      </XStack>
    );
  };

  return (
    <FlatList
      data={results}
      keyExtractor={(item) => `${item.type}-${item.id}`}
      renderItem={renderItem}
      keyboardShouldPersistTaps="handled"
    />
  );
}
