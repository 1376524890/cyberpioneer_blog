import type { AnnouncementConfig } from "../types/announcementConfig";

export const announcementConfig: AnnouncementConfig = {
	// 公告标题，留空则走i18n默认标题
	title: "",

	// 公告内容
	content: "欢迎来到 Cyber先锋社 官方博客！本站刚刚上线，内容持续更新中，欢迎关注。",

	// 是否允许用户关闭公告
	closable: true,

	link: {
		// 启用链接
		enable: true,
		// 链接文本
		text: "了解我们",
		// 链接 URL
		url: "/about/",
		// 内部链接
		external: false,
	},
};
