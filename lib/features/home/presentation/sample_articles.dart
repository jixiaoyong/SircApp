/// Local, bilingual reading examples shared by the list and static detail route.
class SampleArticle {
  const SampleArticle(
    this.titleZh,
    this.titleEn,
    this.summaryZh,
    this.summaryEn,
    this.bodyZh,
    this.bodyEn,
  );

  final String titleZh;
  final String titleEn;
  final String summaryZh;
  final String summaryEn;
  final String bodyZh;
  final String bodyEn;

  String title(bool zh) => zh ? titleZh : titleEn;
  String summary(bool zh) => zh ? summaryZh : summaryEn;
  String body(bool zh) => zh ? bodyZh : bodyEn;
}

const sampleArticleGroups = <List<SampleArticle>>[
  [
    SampleArticle(
      '认识债券',
      'Bonds',
      '认识资产与风险',
      'Understand assets and risk',
      '债券通常约定付息与到期日，但并不等于没有风险。发行方信用、市场利率变化以及能否及时卖出，都会影响持有体验。\n\n阅读时先找出期限、付息方式和提前退出条件，再区分票面利息与实际回报。为近期生活开支准备的资金，应先考虑可用性，而不是只比较收益数字。',
      'A bond usually specifies interest payments and a maturity date, but that does not remove risk. Issuer credit, changing market rates and the ability to sell can all affect the outcome.\n\nStart with the term, payment schedule and exit conditions. Distinguish the stated coupon from the return actually received, and prioritize access to money needed for near-term expenses.',
    ),
    SampleArticle(
      '现金储备怎么安排',
      'Cash reserves',
      '给日常生活留出缓冲空间',
      'Make room for everyday surprises',
      '先列出房租、餐食、交通等必要开支，计算一个月维持生活需要多少现金。应急储备的规模应结合收入稳定性、家庭责任和已有保障来考虑。\n\n把应急用途与旅行、购物等计划分开记录。定期检查余额与取用条件，发生支出后再逐步补充，而不是追求一个适用于所有人的固定数字。',
      'List essential costs such as housing, food and transport to understand a month of basic expenses. A cash buffer depends on income stability, family responsibilities and existing protections.\n\nTrack emergencies separately from planned travel or purchases. Review access conditions and rebuild the buffer after using it rather than aiming for a universal target.',
    ),
    SampleArticle(
      '整理你的数字钱包',
      'Organize your wallet',
      '让常用账户和付款方式更清楚',
      'Keep accounts and payment methods clear',
      '盘点常用银行卡、钱包余额与自动扣款项目，确认每项服务绑定的账户。移除不再使用的支付方式前，先检查是否仍有订阅或待处理退款。\n\n为不同用途设置容易识别的备注，并在每月固定时间检查交易。保留官方客服入口，避免遇到问题时通过陌生链接寻找帮助。',
      'Review cards, wallet balances and recurring payments, noting which account each service uses. Before removing an unused payment method, check subscriptions and pending refunds.\n\nUse recognizable labels for different purposes and review activity monthly. Keep official support details handy instead of following unfamiliar links when a problem occurs.',
    ),
    SampleArticle(
      '读懂一笔交易记录',
      'Read a transaction',
      '从日期、方向和金额核对账目',
      'Check dates, direction and amounts',
      '核对交易时，先确认它是收入还是支出，再查看日期、商户名称和金额。入账日期可能与消费日期不同，周末与跨境交易尤其需要留意。\n\n遇到重复项目时不要立即删除记录。对照银行流水、订单编号和退款状态，保存必要凭证，再通过官方渠道核实。',
      'Check whether a record is incoming or outgoing, then compare the date, merchant and amount. Posting dates may differ from purchase dates, particularly for weekends or cross-border payments.\n\nDo not immediately discard apparent duplicates. Compare statements, order references and refund status, retain receipts and verify through official support.',
    ),
    SampleArticle(
      '建立每月账单清单',
      'A monthly bill checklist',
      '把到期日变成可执行的提醒',
      'Turn due dates into useful reminders',
      '把固定账单按到期日排列，记下金额是否浮动、是否自动扣款以及对应账户。提醒最好安排在到期前，留出核对和转账的时间。\n\n每月检查一次价格变化和不再需要的服务。取消订阅后保存确认记录，并在下一个账期再次检查扣款情况。',
      'Order recurring bills by due date and record variable amounts, automatic payments and the funding account. Set reminders early enough to check details and move money if needed.\n\nReview price changes and unused services each month. Keep cancellation confirmations and check the next statement for further charges.',
    ),
    SampleArticle(
      '和家人讨论共同开支',
      'Shared household expenses',
      '先约定规则，再一起回顾',
      'Agree on a process and review it together',
      '先确定哪些属于共同支出，再讨论分摊方式和记录频率。规则需要照顾实际收入与责任，而不只是简单平均。\n\n为大额购买设置提前沟通的约定。定期一起回顾记录，以具体事实讨论变化，避免把账目核对变成对个人消费习惯的评判。',
      'Define shared costs before deciding how to split and record them. The arrangement should reflect income and responsibilities rather than assuming an equal split always fits.\n\nAgree to discuss larger purchases in advance. Review records together and use concrete details to adjust the process without judging personal spending habits.',
    ),
  ],
  [
    SampleArticle(
      '市场观察从哪里开始',
      'Markets',
      '区分新闻、价格与长期变化',
      'Separate headlines from lasting changes',
      '市场新闻常把价格变化与单一事件联系起来，但短期波动可能有多种原因。阅读时检查消息时间、数据来源与比较区间。\n\n记录自己不理解的术语，并查阅原始说明。不要把热门话题或一天的涨跌当作确定的趋势，也不要仅依据标题做决定。',
      'Market headlines often connect price movements to one event, although short-term changes can have many causes. Check publication dates, original sources and comparison periods.\n\nKeep a list of unfamiliar terms and consult primary explanations. A popular topic or a single day of movement does not establish a reliable trend.',
    ),
    SampleArticle(
      '十分钟每周财务回顾',
      'Weekly finance',
      '用一份小清单回顾本周收支',
      'Review the week with a short checklist',
      '选一个固定时间，浏览本周收入与支出，标记尚未核对的项目。先检查必要账单，再看临时支出是否影响下周安排。\n\n回顾的目标是发现变化，而不是逐笔责备自己。记下一个下周可以执行的小调整，并保留不确定项目等待后续凭证。',
      'Choose a regular time to review weekly income and spending and flag unverified entries. Check essential bills before considering how unexpected costs affect the coming week.\n\nThe aim is to notice changes, not criticize every purchase. Pick one practical adjustment and keep uncertain entries flagged until supporting details arrive.',
    ),
    SampleArticle(
      '安全支付的核对步骤',
      'Secure payments',
      '付款前多一次确认',
      'Pause and verify before paying',
      '付款前核对收款人名称、金额和币种，特别留意通过聊天收到的临时变更。涉及大额转账时，可以通过已知联系方式独立确认。\n\n验证码和支付密码不应提供给他人。若误转或怀疑被欺诈，及时联系银行官方渠道并保留沟通记录，不要继续按陌生人的指示付款。',
      'Verify the recipient, amount and currency, especially when payment details change in a message. For significant transfers, confirm independently through a contact method you already trust.\n\nNever share verification codes or payment passwords. If a payment seems wrong, contact official bank support, preserve messages and stop following unfamiliar payment instructions.',
    ),
    SampleArticle(
      '订阅费用为什么容易被忽略',
      'Spot recurring subscriptions',
      '从小额重复扣款找回预算空间',
      'Notice small charges that repeat',
      '小额订阅分散在不同日期和账户时，很难一眼看到总支出。整理最近几个月流水，按服务名称合并，区分月付、年付与试用期结束后的续费。\n\n对照实际使用频率决定保留哪些服务。关闭自动续费前查看权益截止日，避免把取消续费误认为立即退款。',
      'Subscriptions spread across accounts and dates can hide their combined cost. Group several months of statements by service and distinguish monthly, annual and post-trial renewals.\n\nCompare costs with actual use. Check when access ends before disabling renewal, and do not assume cancellation automatically creates a refund.',
    ),
    SampleArticle(
      '识别假客服的常见信号',
      'Recognize fake support',
      '警惕催促、转账与远程控制要求',
      'Watch for urgency and remote-access requests',
      '声称账户即将冻结、要求转入安全账户或安装远程控制软件，都是需要暂停核实的信号。来电显示与头像也不能证明对方身份。\n\n结束可疑对话后，从银行卡背面或应用内找到官方联系方式。不要使用对方提供的电话号码和链接，也不要为了证明清白展示账户验证码。',
      'Threats of an account freeze, requests to move money to a safe account and remote-control software demands are reasons to stop and verify. Caller IDs and profile pictures are not proof of identity.\n\nEnd suspicious conversations and find official contact details on your card or in the app. Avoid supplied links and never reveal account codes to prove your identity.',
    ),
    SampleArticle(
      '退款到账前要记录什么',
      'Track a refund',
      '分清已申请、已处理与已入账',
      'Separate requested, processed and posted',
      '退款申请成功不一定代表银行已经入账。保存订单号、原交易日期、退款金额和商户预计处理时间，便于后续跟进。\n\n在流水中寻找对应退款时，留意分批退款和不同入账日期。如果超过商户承诺时间，先联系商户核对处理状态，再通过银行官方渠道查询。',
      'An accepted refund request does not necessarily mean the bank has posted it. Keep the order reference, original transaction date, refund amount and expected processing time.\n\nLook for partial refunds and posting dates that differ from the purchase. If the promised time passes, verify the merchant status before checking with official bank support.',
    ),
  ],
  [
    SampleArticle(
      '投资前先了解自己',
      'Investing',
      '从目标、期限和承受能力出发',
      'Start with goals, timing and risk tolerance',
      '学习投资可以先从用途与时间开始：这笔钱何时需要，损失会如何影响生活，是否已经保留必要现金。不同目标不能只用同一收益指标比较。\n\n阅读费用、退出条件和风险披露，并把不理解的问题列出来。理解产品之前不急于行动，过往表现也不能保证未来结果。',
      'Begin with purpose and timing: when will the money be needed, what would a loss mean for daily life, and are essential cash needs covered? A return figure alone cannot compare different goals.\n\nRead fees, exit conditions and risk disclosures and list unanswered questions. Take time to understand a product, and remember that past performance does not guarantee future outcomes.',
    ),
    SampleArticle(
      '给预算留一点弹性',
      'Budgeting',
      '让计划适应真实生活',
      'Build a plan that can adapt',
      '先区分固定开支、可调整开支和不定期的大项，再估算每一类的范围。预算是一份可以更新的计划，不是要求每月数字完全相同。\n\n为维修、礼物等偶发支出留出空间。月末对照实际记录，找出偏差的原因，下一次调整分类或金额，而不是简单认定计划失败。',
      'Separate fixed costs, flexible spending and occasional large expenses, then estimate a range for each. A budget is a plan to update, not a requirement for identical monthly numbers.\n\nAllow space for repairs, gifts and other irregular needs. Compare actual records at month-end and revise categories or amounts based on what changed.',
    ),
    SampleArticle(
      '数字钱包的权限管理',
      'Digital wallet',
      '只保留真正需要的访问权限',
      'Keep only the access you need',
      '检查钱包应用申请的通知、相机和位置等权限，了解每项功能为何需要它们。扫码通常需要相机权限，但不代表所有权限都必须一直开启。\n\n从系统设置定期回顾授权，更新应用和设备系统。换手机或停用设备前，确认已退出账户并按照官方流程移除旧设备。',
      'Review notification, camera and location permissions and understand which feature uses each one. Scanning may need a camera, but that does not mean every permission must remain enabled.\n\nRevisit access in system settings and keep software updated. Before replacing or retiring a device, sign out and remove it through the official process.',
    ),
    SampleArticle(
      '为旅行整理付款准备',
      'Prepare for travel payments',
      '出发前核对币种、费用与备用方案',
      'Check currencies, fees and backup options',
      '出发前了解常用卡的境外使用条件、汇率计算方式与可能的手续费。把交通、住宿押金与日常消费分别考虑，避免低估临时冻结金额。\n\n准备必要的备用付款方式并分开保管。遇到付款页面提供不同币种结算时，阅读汇率和费用说明，再确认选择。',
      'Before traveling, check international card conditions, exchange-rate rules and possible fees. Consider transport, hotel deposits and daily spending separately to account for temporary holds.\n\nKeep an appropriate backup payment option separately. If a checkout offers several settlement currencies, read the rates and fees before confirming.',
    ),
    SampleArticle(
      '把储蓄目标拆成小步骤',
      'Break down a savings goal',
      '用期限和阶段进度检查计划',
      'Use milestones to review progress',
      '为目标写下预计金额与时间，再结合必要开支估算每月可以安排多少。若差距太大，可以调整期限或范围，不必挤压基本生活需要。\n\n按阶段记录进度，同时考虑收入变化与临时支出。定期复核目标是否仍然重要，让计划服务于生活，而不是只追求连续完成的数字。',
      'Write down a target amount and date, then estimate what fits after essential expenses. If the gap is too large, adjust the timing or scope rather than squeezing basic needs.\n\nTrack milestones while allowing for income changes and unexpected costs. Revisit whether the goal still matters instead of focusing only on an unbroken streak.',
    ),
    SampleArticle(
      '整理年度财务资料',
      'Organize annual records',
      '让账单、凭证和保单更容易查找',
      'Make statements and documents easy to find',
      '按年份与用途分类保存账单、重要凭证和保障资料，使用清楚的文件名。先了解当地保存要求，再决定哪些资料适合长期保留。\n\n电子资料应设置适当访问保护并准备备份。分享文件前检查是否含有完整卡号、证件号码等敏感信息，尽量只提供对方真正需要的部分。',
      'Group statements, important receipts and protection documents by year and purpose using clear names. Check local retention requirements before deciding what to keep long term.\n\nProtect digital records and maintain backups. Before sharing, check for full card numbers and identity details and provide only the information actually needed.',
    ),
  ],
];

SampleArticle? sampleArticleForId(String id) {
  final parts = id.split('-');
  if (parts.length != 2) return null;
  final group = int.tryParse(parts[0]);
  final index = int.tryParse(parts[1]);
  if (group == null ||
      index == null ||
      group < 0 ||
      group >= sampleArticleGroups.length ||
      index < 0 ||
      index >= sampleArticleGroups[group].length) {
    return null;
  }
  return sampleArticleGroups[group][index];
}
